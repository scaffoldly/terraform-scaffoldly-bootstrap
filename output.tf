output "main_nameservers" {
  value = module.dns.nameservers
}

output "serverless_apis_create_these_dns_records" {
  value = {
    for stage in module.dns.stage_domains :
    stage.domain => {
      record_type = "NS"
      records     = stage.nameservers
    }
  }
}

output "account_id" {
  value = module.aws_organization.account_id
}
