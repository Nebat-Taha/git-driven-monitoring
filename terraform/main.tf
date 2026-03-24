# terraform/main.tf

# 1. Network Layer
module "vpc" {
  source             = "./modules/vpc"
  project_name       = "monitoring-system"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
}

# 2. Security Layer
module "security_groups" {
  source          = "./modules/security-groups"
  project_name    = "monitoring-system"
  vpc_id          = module.vpc.vpc_id # Passing output from VPC module
  vpc_cidr        = "10.0.0.0/16"
  allowed_mgmt_ip = var.my_ip # We'll define this in variables.tf
}


# 3. Compute Layer
module "ec2" {
  source            = "./modules/ec2"
  project_name      = "monitoring-system"
  public_subnet_id  = module.vpc.public_subnet_id
  security_group_id = module.security_groups.security_group_id
  key_name          = "monitoring-key" # We need to create this in the console once
}
