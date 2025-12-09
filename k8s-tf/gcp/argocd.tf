resource "time_sleep" "wait_for_gke" {
  count           = (var.argocd_deployment) ? 1 : 0
  depends_on      = [module.gke]
  create_duration = "2m"
}

resource "kubernetes_secret" "external_secrets_operator" {
  count      = (var.argocd_deployment) ? 1 : 0
  depends_on = [time_sleep.wait_for_gke]

  metadata {
    name      = "external-secrets-operator-secret"
    namespace = "kube-system"
  }

  data = {
    "secret-access-credentials" = file(var.sa_creds)
  }
}

resource "helm_release" "argocd" {
  count            = (var.argocd_deployment) ? 1 : 0
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_version
  namespace        = var.argocd_namespace
  create_namespace = true

  set = [
    {
      name  = "server.service.type"
      value = "LoadBalancer"
    },
    {
      name  = "server.ingress.enabled"
      value = "false"
    }
  ]

  depends_on = [time_sleep.wait_for_gke]
}

resource "time_sleep" "wait_for_argocd" {
  count           = (var.argocd_deployment) ? 1 : 0
  depends_on      = [helm_release.argocd]
  create_duration = "3m"
}

data "kubernetes_service" "argocd_server" {
  count      = (var.argocd_deployment) ? 1 : 0
  depends_on = [time_sleep.wait_for_argocd]
  metadata {
    name      = "argocd-server"
    namespace = var.argocd_namespace
  }
}

data "kubernetes_secret" "argocd_admin_secret" {
  count      = (var.argocd_deployment) ? 1 : 0
  depends_on = [time_sleep.wait_for_argocd]
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.argocd_namespace
  }
}
