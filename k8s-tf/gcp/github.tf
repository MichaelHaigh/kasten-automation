resource "local_file" "addons_kastenio_external_secret" {
  filename = "../../argocd/addons/kasten-io/external-secret.yaml"
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

resource "github_repository_file" "addons_kastenio_external_secret" {
  repository          = var.github_repo
  branch              = "argocd-setup" # change to main when merging to main
  file                = "../../argocd/addons/kasten-io/external-secret.yaml"
  content             = local_file.addons_kastenio_external_secret.content
  commit_message      = "chore(deploy): update addon yaml from Terraform for ${terraform.workspace} apply"
  overwrite_on_create = true
}

resource "local_file" "addons_kastenprofiles_location" {
  filename = "../../argocd/addons/kasten-profiles/location.yaml"
  content  = <<YAML
# Auto-generated file, do not edit directly
apiVersion: config.kio.kasten.io/v1alpha1
kind: Profile
metadata:
  name: k10-${terraform.workspace}-${var.creator_label}
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
  repository          = var.github_repo
  branch              = "argocd-setup" # change to main when merging to main
  file                = "../../argocd/addons/kasten-profiles/location.yaml"
  content             = local_file.addons_kastenprofiles_location.content
  commit_message      = "chore(deploy): update addon yaml from Terraform for ${terraform.workspace} apply"
  overwrite_on_create = true
}
