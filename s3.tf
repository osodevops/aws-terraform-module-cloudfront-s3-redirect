resource "aws_s3_bucket" "main" {
  provider = aws.main
  bucket   = var.fqdn
  acl      = "private"
  policy   = data.aws_iam_policy_document.bucket_policy.json

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