provider "aws" {
  alias   = "main"
  region  = "eu-west-2"
  version = "~> 3.8.0"
  # description = "AWS Region for S3 and other resources"
}

provider "aws" {
  region = "us-east-1"
  alias   = "cloudfront"
  version = "~> 3.8.0"
  # description = "AWS Region for Cloudfront (ACM certs only supports us-east-1)"
}

