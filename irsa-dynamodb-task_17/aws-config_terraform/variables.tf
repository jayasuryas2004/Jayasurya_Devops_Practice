variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

variable "oidc_provider_arn" {
  description = "The ARN of the EKS cluster OIDC Provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "The URL of the EKS cluster OIDC Provider (without https://)"
  type        = string
}

variable "namespace" {
  description = "The Kubernetes namespace where the app will run"
  type        = string
  default     = "default"
}

variable "service_account_name" {
  description = "The name of the Kubernetes Service Account"
  type        = string
  default     = "dynamodb-sa"
}

variable "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table the app needs to access"
  type        = string
}