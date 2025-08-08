variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the ASG"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for instances"
  type        = string
}

variable "desired_capacity" {
  description = "Number of Nomad/Consul server instances"
  type        = number
}

variable "zone_name" {
  description = "Route53 zone name"
  type        = string
}
