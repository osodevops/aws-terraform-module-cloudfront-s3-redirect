resource "aws_s3_bucket" "main" {
  bucket   = var.bucket_name
  acl      = "private"
  region   = data.aws_region.current.name
  website {
    redirect_all_requests_to = var.redirect_target
  }

  force_destroy = var.force_destroy

  tags = merge(
    var.common_tags,
    {
      "Name" = var.fqdn
    },
  )
}