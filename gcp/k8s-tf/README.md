# GKE / Kasten Automation

This Terraform code deploys:

* [argocd.tf](./argocd.tf): *if* `var.argocd_deployment` is set to `true`, ArgoCD is deployed via the [Terraform Helm Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
* [gcs.tf](./gcs.tf): a Google Cloud Storage bucket which is used for application backups via Kasten
* [github.tf](./github.tf): dynamic ArgoCD application and addon YAML specification files which are then committed to git using the [Terraform GitHub Provider](https://registry.terraform.io/providers/integrations/github/latest)
* [gke.tf](./gke.tf): a **zonal** GKE cluster, with most other options configurable via variables.
* [main.tf](./main.tf): required provider versions, including credential file information
* [vpc.tf](./vpc.tf): A new VPC, subnetwork with necessary secondary networks, firewall, router and NAT gateway for egress internet access, and GCNV network peering.

Please see the [main readme](../README.md) for information on how to deploy.

## Credentials

There are three main credentials which are required:

* `github_repo_token`: a local file which contains a [fine-grained token](https://github.blog/security/application-security/introducing-fine-grained-personal-access-tokens-for-github/) for your GitHub account:
  * Optionally (but recommended) constrained to your `kasten-automation` repository
  * **Read** access to metadata
  * **Read** and **Write** access to code
* `sa_creds`: a local file to the [service account credential](https://cloud.google.com/iam/docs/service-account-creds#key-types) which is used to deploy Terraform resources with the following permissions:
  * roles/compute.admin
  * roles/compute.securityAdmin
  * roles/container.admin
  * roles/container.clusterAdmin
  * roles/container.developer
  * roles/iam.serviceAccountAdmin
  * roles/iam.serviceAccountUser
  * roles/resourcemanager.projectIamAdmin
  * roles/secretmanager.admin
  * roles/storage.admin
* `k10_sa_creds`: a local file to the [service account credential](https://cloud.google.com/iam/docs/service-account-creds#key-types) which is [used by Kasten](https://docs.kasten.io/latest/install/google/google#using-a-separate-gcp-service-account) to manage `volumesnapshot` in the GCP account, with the `compute.storageAdmin` permission

## Other Settings

### GitHub Settings

All of these variables *must* be updated to match your GitHub owner and repository information.

### GCP Settings

All of these variables *must* be updated to match your GCP service accounts, user, and project information.

### Authorized Networks

The bottom of the `tfvars` file contains an `authorized_networks` list which permits access to the deployed resources. You should update the values (and optionally add additional values) to match any IP ranges that you wish to access the environment from (`curl http://checkip.amazonaws.com` is a useful command to figure out your IP address).
