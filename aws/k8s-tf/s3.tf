resource "aws_s3_bucket" "backup_target" {
  bucket        = "${var.creator_tag}-${terraform.workspace}-k10"
  force_destroy = true

  tags = {
    Env     = "${var.creator_tag}-${terraform.workspace}"
    Name    = "${var.creator_tag}-${terraform.workspace}-k10"
    Creator = "${var.creator_tag}"
  }
}

resource "aws_s3_bucket_public_access_block" "backup_target" {
  bucket = aws_s3_bucket.backup_target.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
