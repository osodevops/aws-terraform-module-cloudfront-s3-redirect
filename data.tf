# data "aws_region" "main" {
#   provider = aws.main
# }

data "aws_region" "current" {
  provider = aws.main
}