#  The prod and dev it will easy we to change so i used
variable "env" {
    description = "The environment name" # dev or prod
    type = string
}

variable "vpc_cidr" {
    description = "The primary description to vpc"
    type = string
}

variable "public_subnet_cidr" {
    description = "The public subnet cidr"
    type = list(string)
}

variable "private_subnet_cidr" {
    description = "The private subnet cidr"
    type = list(string)
}

variable "availability_zone" {
    description = "The availability zone for the vpc like us-east-1,us-east-2"
    type = list(string)
}

variable "cluster_name" {
    description = "The eks cluster name"
    type = string
}
