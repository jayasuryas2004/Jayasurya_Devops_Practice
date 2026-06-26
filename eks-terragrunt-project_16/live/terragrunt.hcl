# 1. Automatically generate the AWS Provider block for all child folders
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "ap-south-1"
}
EOF
}

# 2. Configure Remote State (Stores your terraform state file safely in S3)
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "jayasurya-eks-state-apsouth1-2026-new"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    # ADD THIS LINE to prevent S3 endpoint lookups from failing in specific network setups
    dynamodb_table          = "jayasurya-eks-lock-table-2026-new"
    skip_metadata_api_check = true 
  }
}