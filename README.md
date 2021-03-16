[![OSO DevOps][logo]](https://osodevops.io)

# aws-terraform-module-cloudfront-s3-redirect
---

This project is part of our open source DevSecOps adoption approach. 

It's 100% Open Source and licensed under the [APACHE2](LICENSE).

This module deploys and configures a S3 website behind a Cloudfront distribution, allowing you to do a serverless domain name redirect. In order to use this module we assume the following is present:

* it runs HTTPS via Amazon's Certificate Manager ("ACM")
* its domain is backed by a Route53 zone
* and of course, your AWS account provides you access to all these resources necessary.

This module is a pair with
[aws-terraform-module-cloudfront](https://github.com/osodevops/aws-terraform-module-cloudfront),
which handles hosting of a static S3 website with CloudFront and ACM.

A diagram of the solution can be seen below: 
![redirect-solution-diagram](s3-redirect-cloudfront.png)

The solution consists of the following services:
* TO BE UPDATED

## Usage

Include this repository as a module in your existing terraform code:
```hcl
# AWS Region for S3 and other resources
provider "aws" {
  region = "eu-west-2"
  alias = "main"
}

# AWS Region for Cloudfront (ACM certs only supports us-east-1)
provider "aws" {
  region = "us-east-1"
  alias = "cloudfront"
}

# Variables
variable "fqdn" {
  description = "The fully-qualified domain name root of the resulting S3 website."
  default     = "example.com"
}

variable "redirect_target" {
  description = "The fully-qualified domain name to redirect to."
  default     = "www.example.com"
}

# Using this module
module "main" {
  source = "github.com/osodevops/aws-terraform-module-cloudfront-s3-redirect"

  fqdn = "${var.fqdn}"
  redirect_target = "${var.redirect_target}"
  ssl_certificate_arn = "${aws_acm_certificate_validation.cert.certificate_arn}"

  refer_secret = "${base64sha512("REFER-SECRET-19265125-${var.fqdn}-52865926")}"
  force_destroy = "true"
  priceclass = "PriceClass_200"

  providers = {
    aws.main = aws.main
    aws.cloudfront = aws.cloudfront
  }

  # Optional WAF Web ACL ID, defaults to none.
  web_acl_id = "${data.terraform_remote_state.site.waf-web-acl-id}"
}

# ACM Certificate generation

resource "aws_acm_certificate" "cert" {
  provider          = "aws.cloudfront"
  domain_name       = "${var.fqdn}"
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  provider = "aws.cloudfront"
  name     = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type     = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id  = "${data.aws_route53_zone.main.id}"
  records  = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl      = 60
}

resource "aws_acm_certificate_validation" "cert" {
  provider                = "aws.cloudfront"
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

# Route 53 record for the static site

data "aws_route53_zone" "main" {
  provider     = "aws.main"
  name         = "${var.fqdn}"
  private_zone = false
}

resource "aws_route53_record" "web" {
  provider = "aws.main"
  zone_id  = "${data.aws_route53_zone.main.zone_id}"
  name     = "${var.fqdn}"
  type     = "A"

  alias {
    name    = "${module.main.cf_domain_name}"
    zone_id = "${module.main.cf_hosted_zone_id}"
    evaluate_target_health = false
  }
}

# Outputs

output "s3_bucket_id" {
  value = "${module.main.s3_bucket_id}"
}

output "s3_domain" {
  value = "${module.main.s3_website_endpoint}"
}

output "s3_hosted_zone_id" {
  value = "${module.main.s3_hosted_zone_id}"
}

output "cloudfront_domain" {
  value = "${module.main.cf_domain_name}"
}

output "cloudfront_hosted_zone_id" {
  value = "${module.main.cf_hosted_zone_id}"
}

output "cloudfront_distribution_id" {
  value = "${module.main.cf_distribution_id}"
}

output "route53_fqdn" {
  value = "${aws_route53_record.web.fqdn}"
}

output "acm_certificate_arn" {
  value = "${aws_acm_certificate_validation.cert.certificate_arn}"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws_region | Region used in AWS | string | n/a | yes |

## Help

**Got a question?**

File a GitHub [issue](https://github.com/osodevops/aws-terraform-module-cloudfront-s3-redirect/issues), send us an [email][email] or tweet us [twitter][twitter].

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/osodevops/aws-terraform-module-cloudfront-s3-redirect/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing this project or help out with our other projects, we would love to hear from you! Shoot us an [email][email].

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!

## Copyrights

Copyright © 2018-2019 [OSO DevOps](https://osodevops.io)

## License 

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.

## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## About

[![OSO DevOps][logo]][website]

We are a cloud consultancy specialising in transforming technology organisations through DevOps practices. We help organisations accelerate their capabilities for application delivery and minimize the time-to-market for software-driven innovation. 

Check out [our other projects][github], [follow us on twitter][twitter], or [hire us][hire] to help with your cloud strategy and implementation.

  [logo]: https://osodevops.io/assets/images/logo-purple-b3af53cc.svg
  [website]: https://osodevops.io/
  [github]: https://github.com/orgs/osodevops/
  [hire]: https://osodevops.io/contact/
  [linkedin]: https://www.linkedin.com/company/oso-devops
  [twitter]: https://twitter.com/osodevops
  [email]: https://www.osodevops.io/contact/
