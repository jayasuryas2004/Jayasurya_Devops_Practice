include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

locals {
  # This will automatically read the PROD env.yaml!
  env_vars = yamldecode(file(find_in_parent_folders("env.yaml")))
}

inputs = {
  env                 = local.env_vars.env
  cluster_name        = local.env_vars.cluster_name
  vpc_cidr            = local.env_vars.vpc_cidr
  availability_zone   = local.env_vars.availability_zone
  public_subnet_cidr  = local.env_vars.public_subnet_cidr
  private_subnet_cidr = local.env_vars.private_subnet_cidr
}