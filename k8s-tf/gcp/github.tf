resource "local_file" "addons_externalsecrets_clustersecretstore" {
  count    = (var.argocd_deployment) ? 1 : 0
  filename = "~/kasten-automation/argocd/addons/external-secrets/cluster-secret-store.yaml"
  content  = <<YAML
# Auto-generated file, do not edit directly
apiVersion: external-secrets.io/v1
kind: ClusterSecretStore
metadata:
  name: cloud-cluster-secret-store
spec:
  provider:
    gcpsm:
      auth:
        secretRef:
          secretAccessKeySecretRef:
            name: external-secrets-operator-secret
            key: secret-access-credentials
            namespace: kube-system
      projectID: ${var.gcp_project}
YAML
}

resource "github_repository_file" "addons_externalsecrets_clustersecretstore" {
  count               = (var.argocd_deployment) ? 1 : 0
  repository          = var.github_repo
  branch              = "argocd-setup" # change to main when merging to main
  file                = "argocd/addons/external-secrets/cluster-secret-store.yaml"
  content             = local_file.addons_externalsecrets_clustersecretstore[0].content
  commit_message      = "automated(${terraform.workspace}): update cluster-secret-store.yaml via 'terraform apply'"
  overwrite_on_create = true
}

resource "local_file" "addons_kastenio_externalsecret" {
  count    = (var.argocd_deployment) ? 1 : 0
  filename = "~/kasten-automation/argocd/addons/kasten-io/external-secret.yaml"
  content  = <<YAML
# Auto-generated file, do not edit directly
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: k10-sa-key
  namespace: kasten-io
spec:
  secretStoreRef:
    name: cloud-cluster-secret-store
    kind: ClusterSecretStore
  target:
    name: k10secret-gcp-sa-key
    creationPolicy: Owner
  data:
  - secretKey: project-id
    remoteRef:
      key: projectid-${terraform.workspace}-${var.creator_label}
  - secretKey: service-account.json
    remoteRef:
      key: k10-sa-${terraform.workspace}-${var.creator_label}
YAML
}

resource "github_repository_file" "addons_kastenio_externalsecret" {
  count               = (var.argocd_deployment) ? 1 : 0
  repository          = var.github_repo
  branch              = "argocd-setup" # change to main when merging to main
  file                = "argocd/addons/kasten-io/external-secret.yaml"
  content             = local_file.addons_kastenio_externalsecret[0].content
  commit_message      = "automated(${terraform.workspace}): update external-secret.yaml via 'terraform apply'"
  overwrite_on_create = true
}

resource "local_file" "addons_kastenprofiles_infra" {
  count    = (var.argocd_deployment) ? 1 : 0
  filename = "~/kasten-automation/argocd/addons/kasten-profiles/infra.yaml"
  content  = <<YAML
# Auto-generated file, do not edit directly
kind: Profile
apiVersion: config.kio.kasten.io/v1alpha1
metadata:
  name: gcp-infra-${terraform.workspace}-${var.creator_label}
  namespace: kasten-io
spec:
  infra:
    credential:
      secretType: GcpServiceAccountKey
      secret:
        apiVersion: v1
        kind: secret
        name: k10secret-gcp-sa-key
        namespace: kasten-io
    type: GCP
  type: Infra
YAML
}

resource "github_repository_file" "addons_kastenprofiles_infra" {
  count               = (var.argocd_deployment) ? 1 : 0
  repository          = var.github_repo
  branch              = "argocd-setup" # change to main when merging to main
  file                = "argocd/addons/kasten-profiles/infra.yaml"
  content             = local_file.addons_kastenprofiles_infra[0].content
  commit_message      = "automated(${terraform.workspace}): update infra.yaml via 'terraform apply'"
  overwrite_on_create = true
}

resource "local_file" "addons_kastenprofiles_location" {
  count    = (var.argocd_deployment) ? 1 : 0
  filename = "~/kasten-automation/argocd/addons/kasten-profiles/location.yaml"
  content  = <<YAML
# Auto-generated file, do not edit directly
apiVersion: config.kio.kasten.io/v1alpha1
kind: Profile
metadata:
  name: gcp-location-${terraform.workspace}-${var.creator_label}
  namespace: kasten-io
spec:
  locationSpec:
    credential:
      secret:
        apiVersion: v1
        kind: secret
        name: k10secret-gcp-sa-key
        namespace: kasten-io
      secretType: GcpServiceAccountKey
    objectStore:
      name: ${google_storage_bucket.backup_target.name}
      region: ${var.gcp_region}
  type: Location
YAML
}

resource "github_repository_file" "addons_kastenprofiles_location" {
  count               = (var.argocd_deployment) ? 1 : 0
  repository          = var.github_repo
  branch              = "argocd-setup" # change to main when merging to main
  file                = "argocd/addons/kasten-profiles/location.yaml"
  content             = local_file.addons_kastenprofiles_location[0].content
  commit_message      = "automated(${terraform.workspace}): update location.yaml via 'terraform apply'"
  overwrite_on_create = true
}
