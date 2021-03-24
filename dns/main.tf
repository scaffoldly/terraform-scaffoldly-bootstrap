terraform {
  required_version = ">= 0.14"
  experiments      = [module_variable_optional_attrs]
}

provider "aws" {
  alias = "dns"
}

variable "dns_provider" {
  type = string
}
variable "serverless_api_subdomain" {
  type = string
}

variable "stages" {
  type = map(
    object({
      domain           = string
      subdomain_suffix = optional(string)
    })
  )
}

resource "aws_route53_delegation_set" "main" {}

module "dns" {
  for_each = var.stages
  source   = "./stage-dns"

  dns_provider      = var.dns_provider
  stage             = each.key
  domain            = each.value.domain
  subdomain         = var.serverless_api_subdomain
  subdomain_suffix  = each.value.subdomain_suffix != null ? each.value.subdomain_suffix : ""
  delegation_set_id = aws_route53_delegation_set.main.id

  providers = {
    aws.dns = aws.dns
  }
}

output "stage_domains" {
  value = {
    for domain in module.dns :
    domain.stage => {
      domain                = domain.domain
      subdomain             = domain.subdomain
      subdomain_suffix      = domain.subdomain_suffix
      serverless_api_domain = domain.serverless_api_domain
      certificate_arn       = domain.certificate_arn
      dns_provider          = domain.dns_provider
      dns_domain_id         = domain.dns_domain_id
    }
  }
}
