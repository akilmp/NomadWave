output "private_ips" {
  value = data.aws_instances.nomad.private_ips
}

output "zone_id" {
  value = aws_route53_zone.this.zone_id
}

output "iam_role_arn" {
  value = aws_iam_role.this.arn
}
