variable "fqdn" {
  type        = string
  description = "The FQDN of the website and also name of the S3 bucket"
}

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
}

variable "redirect_target" {
  type        = string
  description = "The FQDN to redirect to"
}

variable "force_destroy" {
  type        = string
  description = "The force_destroy argument of the S3 bucket"
  default     = "false"
}

variable "ssl_certificate_arn" {
  type        = string
  description = "ARN of the certificate covering var.fqdn"
}

variable "web_acl_id" {
  type        = string
  description = "WAF Web ACL ID to attach to the CloudFront distribution, this is optional"
  default     = ""
}

variable "refer_secret" {
  type        = string
  description = "A secret string to authenticate CF requests to S3"
  default     = "123-VERY-SECRET-456"
}

variable "region" {
  type        = string
  description = "S3 bucket region"
  default     = "eu-west-2"
}

variable "priceclass" {
  type        = string
  description = "Pick the price class to use; PriceClass_100, PriceClass_200, PriceClass_All"
  default     = "PriceClass_100"  
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags used"
  default     = {}
}