resource "time_sleep" "wait_for_gke" {
  depends_on      = [module.gke]
  create_duration = "2m"
}

resource "helm_release" "argocd" {
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
  depends_on      = [helm_release.argocd]
  create_duration = "3m"
}

data "kubernetes_service" "argocd_server" {
  depends_on = [time_sleep.wait_for_argocd]
  metadata {
    name      = "argocd-server"
    namespace = var.argocd_namespace
  }
}

data "kubernetes_secret" "argocd_admin_secret" {
  depends_on = [time_sleep.wait_for_argocd]
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.argocd_namespace
  }
}
