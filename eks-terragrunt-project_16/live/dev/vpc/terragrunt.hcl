include "root" {
  path = find_in_parent_folders()
}

# Point to your VPC blueprint
terraform {
  source = "../../../modules/vpc"
}

# Read the dev IPs from env.yaml
locals {
  env_vars = yamldecode(file(find_in_parent_folders("env.yaml")))
}

# Pass the variables into the module
inputs = {
  env                 = local.env_vars.env
  cluster_name        = local.env_vars.cluster_name
  vpc_cidr            = local.env_vars.vpc_cidr
  availability_zone   = local.env_vars.availability_zone
  public_subnet_cidr  = local.env_vars.public_subnet_cidr
  private_subnet_cidr = local.env_vars.private_subnet_cidr
}