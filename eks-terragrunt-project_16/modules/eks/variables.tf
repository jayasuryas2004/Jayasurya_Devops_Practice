variable "env" {
  description = "The environment name (e.g., dev, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30" 
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster and nodes"
  type        = list(string)
}