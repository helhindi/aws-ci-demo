terraform {
  required_version = ">= 0.12.0"
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "future-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.6.0"

  name                 = "${local.cluster_name}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    env         = "d"
    environment = "dev"
    Name        = "d-eu-west-2-eks"
    owner       = "Future Admin"
    owner_email = "admin@future.air"
    project     = "core-infra"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source       = "./modules/terraform-aws-eks"
  cluster_name = local.cluster_name

  vpc_id               = "${module.vpc.vpc_id}"
  subnets              = "${module.vpc.private_subnets}"

  tags = {
    Environment = "${var.env[var.environment]}"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  worker_groups = [
    {
      name                          = "jenkins-master"
      instance_type                 = "m5d.large"
      additional_userdata           = "echo jenkins master"
      asg_desired_capacity          = 1
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "worker-nodes"
      instance_type                 = "t3.large"
      additional_userdata           = "echo jenkins node"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 3
    },
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  map_roles                            = var.map_roles
  map_users                            = var.map_users
  map_accounts                         = var.map_accounts
}

# Needed for cluster-autoscaler
resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryPowerUser" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = module.eks.worker_iam_role_name
}

# Create S3 bucket for KMS
resource "aws_s3_bucket" "vault-unseal" {
  bucket = "vault-unseal.${var.region}"
  acl    = "private"

  versioning {
    enabled = false
  }
}

# Create KMS key
resource "aws_kms_key" "bank_vault" {
  description = "KMS Key for bank vault unseal"
}

# Create DynamoDB table
resource "aws_dynamodb_table" "vault-data" {
  name           = "vault-data"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "Path"
  range_key      = "Key"
  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }
}

# Create service account for vault. Should the policy
resource "aws_iam_user" "vault" {
  name = "vault_${var.region}"
}

data "aws_iam_policy_document" "vault" {
  statement {
    sid = "DynamoDB"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
      "dynamodb:DescribeReservedCapacityOfferings",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:ListTables",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:CreateTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:Scan",
      "dynamodb:DescribeTable"
    ]
    resources = ["${aws_dynamodb_table.vault-data.arn}"]
  }
  statement {
    sid = "S3"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = ["${aws_s3_bucket.vault-unseal.arn}/*"]
  }
  statement {
    sid = "S3List"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = ["${aws_s3_bucket.vault-unseal.arn}"]
  }
  statement {
    sid = "KMS"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["${aws_kms_key.bank_vault.arn}"]
  }
}

resource "aws_iam_user_policy" "vault" {
  name = "vault_${var.region}"
  user = aws_iam_user.vault.name

  policy = data.aws_iam_policy_document.vault.json
}

resource "aws_iam_access_key" "vault" {
  user = aws_iam_user.vault.name
}


# Output KMS key id, S3 bucket name and secret name in the form of jx install options
output "jx_params" {
  value = "--provider=eks --gitops --no-tiller --vault --aws-dynamodb-region=${var.region} --aws-dynamodb-table=${aws_dynamodb_table.vault-data.name} --aws-kms-region=${var.region} --aws-kms-key-id=${aws_kms_key.bank_vault.key_id} --aws-s3-region=${var.region}  --aws-s3-bucket=${aws_s3_bucket.vault-unseal.id} --aws-access-key-id=${aws_iam_access_key.vault.id} --aws-secret-access-key=${aws_iam_access_key.vault.secret}"
}
