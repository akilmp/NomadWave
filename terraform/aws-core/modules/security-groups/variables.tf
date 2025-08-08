variable "name" {
  description = "Security group name prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "ingress_cidrs" {
  description = "CIDR blocks allowed to access Nomad/Consul"
  type        = list(string)
}
