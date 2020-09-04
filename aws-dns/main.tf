variable "stage" {}
variable "domain" {}
variable "delegation_set_id" {}

resource "aws_route53_zone" "zone" {
  name              = var.domain
  delegation_set_id = var.delegation_set_id
}

resource "aws_acm_certificate" "apex" {
  domain_name       = var.domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "subdomain_wildcard" {
  domain_name       = "*.${var.domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "verification_record" {
  for_each = {
    for dvo in aws_acm_certificate.apex.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = aws_route53_zone.zone.zone_id
}

output "domain" {
  value = var.domain
}

output "stage" {
  value = var.stage
}

output "apex_certificate_arn" {
  value = aws_acm_certificate.apex.arn
}

output "wildcard_certificate_arn" {
  value = aws_acm_certificate.subdomain_wildcard.arn
}
