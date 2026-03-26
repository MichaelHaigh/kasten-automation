# Cleanup ArgoCD applications and cloud resources before destroying infrastructure.
# Phase 1: Delete ArgoCD apps that own HTTPRoutes (while ExternalDNS is still running)
#           so ExternalDNS can clean up Cloudflare DNS records.
# Phase 2: Delete all remaining ArgoCD apps (including ExternalDNS itself).
# Phase 3: Delete any remaining Gateway/LoadBalancer resources for cloud cleanup.
resource "null_resource" "k8s_cleanup" {
  triggers = {
    cluster_name    = azurerm_kubernetes_cluster.aks_cluster.name
    resource_group  = azurerm_resource_group.aks_resource_group.name
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks_cluster
  ]

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      az aks get-credentials --resource-group ${self.triggers.resource_group} --name ${self.triggers.cluster_name} --overwrite-existing &&
      kubectl delete application -n argocd pacman kasten-io argocd-gateway envoy-gateway-config --ignore-not-found &&
      sleep 60 &&
      kubectl delete applications -n argocd --all --ignore-not-found &&
      sleep 30 &&
      kubectl delete gateway --all-namespaces --all --ignore-not-found &&
      kubectl delete svc --all-namespaces --field-selector spec.type=LoadBalancer &&
      sleep 90 || true
    EOT
  }
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                                = "${var.creator_tag}-${terraform.workspace}-aks"
  location                            = azurerm_resource_group.aks_resource_group.location
  resource_group_name                 = azurerm_resource_group.aks_resource_group.name
  dns_prefix                          = "${var.creator_tag}-${terraform.workspace}"
  kubernetes_version                  = var.aks_kubernetes_version
  private_cluster_enabled             = false
  private_cluster_public_fqdn_enabled = false
  azure_policy_enabled                = false

  api_server_access_profile {
    authorized_ip_ranges = var.authorized_networks[*].cidr_block
  }

  default_node_pool {
    name            = "default"
    vnet_subnet_id  = azurerm_subnet.aks_node_subnet.id
    node_count      = var.aks_node_count
    vm_size         = var.aks_image_size
    os_disk_size_gb = var.aks_os_disk_size_gb

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "${terraform.workspace}"
    creator     = "${var.creator_tag}"
  }

  network_profile {
    network_plugin = "kubenet"
    service_cidr   = var.aks_services_cidr
    pod_cidr       = var.aks_pods_cidr
    dns_service_ip = var.aks_services_dns_ip
  }
}
