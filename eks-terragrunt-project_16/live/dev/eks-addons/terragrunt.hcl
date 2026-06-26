include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/eks-addons"
}

dependency "eks" {
  config_path = "../eks"
  
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    cluster_name                       = "placeholder"
    cluster_endpoint                   = "https://placeholder"
    cluster_certificate_authority_data = "cGxhY2Vob2xkZXIK"
    oidc_provider_arn                  = "arn:aws:iam::000000000000:oidc-provider/placeholder"
    oidc_provider_url                  = "https://oidc.placeholder"
  }
}

inputs = {
  env                                = "dev"
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  oidc_provider_arn                  = dependency.eks.outputs.oidc_provider_arn
  oidc_provider_url                  = dependency.eks.outputs.oidc_provider_url
}