# 1. Include the Master file (gets the provider and backend)
include "root" {
  path = find_in_parent_folders()
}

# 2. Point to your EKS blueprint
terraform {
  source = "../../../modules/eks"
}

# 3. Read the dev variables from env.yaml
locals {
  env_vars = yamldecode(file(find_in_parent_folders("env.yaml")))
}

# 4. CRITICAL DEPENDENCY: Tell it to wait for the VPC to be built first
dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    private_subnet_ids = ["subnet-mock1", "subnet-mock2"]
  }
}

# 5. Pass the variables into the EKS module
inputs = {
  env                = local.env_vars.env
  cluster_name       = local.env_vars.cluster_name
  
  # Take the subnet IDs created by the VPC and give them to EKS!
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids 
}