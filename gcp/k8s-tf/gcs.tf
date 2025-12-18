resource "google_storage_bucket" "backup_target" {
  name          = "k10-${terraform.workspace}-${var.creator_label}"
  location      = var.gcp_region
  force_destroy = true
  storage_class = "REGIONAL"
}
