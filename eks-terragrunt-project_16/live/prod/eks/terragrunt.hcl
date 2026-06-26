include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/eks"
}

locals {
  env_vars = yamldecode(file(find_in_parent_folders("env.yaml")))
}

dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    private_subnet_ids = ["subnet-mock1", "subnet-mock2"]
  }
}

inputs = {
  env                = local.env_vars.env
  cluster_name       = local.env_vars.cluster_name
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids 
}
