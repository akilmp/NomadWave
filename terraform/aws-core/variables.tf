variable "region" {
  description = "AWS region"
  type        = string
}

variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "ingress_cidrs" {
  description = "CIDR blocks allowed for ingress"
  type        = list(string)
}

variable "server_count" {
  description = "Number of Nomad/Consul servers"
  type        = number
}

variable "zone_name" {
  description = "Route53 hosted zone name"
  type        = string
}
