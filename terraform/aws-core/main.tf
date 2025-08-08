module "vpc" {
  source = "./modules/vpc"
  name   = var.project
  cidr   = var.vpc_cidr
}

module "subnets" {
  source          = "./modules/subnets"
  name            = var.project
  vpc_id          = module.vpc.id
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "security_groups" {
  source        = "./modules/security-groups"
  name          = var.project
  vpc_id        = module.vpc.id
  ingress_cidrs = var.ingress_cidrs
}

module "nomad_consul" {
  source            = "./modules/nomad-consul-asg"
  name              = var.project
  subnet_ids        = module.subnets.private_subnet_ids
  security_group_id = module.security_groups.id
  desired_capacity  = var.server_count
  zone_name         = var.zone_name
}
