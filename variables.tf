variable "region" {
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment name: 'dev', 'staging', 'production'"
  type        = map

  default = {
    dev     = "dev"
    staging = "staging"
    prod    = "prod"
  }
}

variable "env" {
  description = "Environment letter: 'd', 's', 'p'" #"${element(split("", ${var.environment}), 2)}"
  type        = map

  default = {
    dev        = "d"
    staging    = "s"
    production = "p"
  }
}

variable "profiles" {
  description = "Environment letter: 'dev', 'prod'"
  type        = map

  default = {
    dev        = "dev"
    production = "prod"
  }
}

variable "domain" {
  description = "Domain to use for the cluster resource deployment"
  default = "elhindi.org"
}

variable "bucket_domain" {
    description = "Suffix for S3 bucket used for vault unseal operation"
    default     = "unseal"
}

variable "key_name" {
  default = "ci-demo-key"
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = [
    # "777777777777",
    # "888888888888",
  ]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    # {
    #   rolearn  = "arn:aws:iam::66666666666:role/role1"
    #   username = "role1"
    #   groups   = ["system:masters"]
    # },
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    # {
    #   userarn  = "arn:aws:iam::66666666666:user/user1"
    #   username = "user1"
    #   groups   = ["system:masters"]
    # },
    # {
    #   userarn  = "arn:aws:iam::66666666666:user/user2"
    #   username = "user2"
    #   groups   = ["system:masters"]
    # },
  ]
}
