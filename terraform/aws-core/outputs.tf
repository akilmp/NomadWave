output "nomad_server_private_ips" {
  description = "Private IPs of Nomad/Consul servers"
  value       = module.nomad_consul.private_ips
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID"
  value       = module.nomad_consul.zone_id
}

output "nomad_server_role_arn" {
  description = "IAM role ARN for Nomad/Consul servers"
  value       = module.nomad_consul.iam_role_arn
}
