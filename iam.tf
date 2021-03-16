resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.aws_s3_bucket.id
  policy = data.aws_iam_policy_document.cloudfbucket_policy.json
}

data "aws_iam_policy_document" "bucket_policy" {
  provider = aws.main

  statement {
    # sid = "AllowCFOriginAccess"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.fqdn}/*",
    ]

    # condition {
    #   test     = "StringEquals"
    #   variable = "aws:UserAgent"

    #   values = [
    #     var.refer_secret,
    #   ]
    # }

    principals {
      type = "AWS"

      identifiers = [
        aws_cloudfront_origin_access_identity.current.iam_arn,
      ]
    }
  }
}