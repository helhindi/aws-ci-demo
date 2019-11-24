resource "aws_kms_key" "ssm_param" {
  description = "SSM Param Store KMS key unseal"
}

# module "ssm_param_ecr-key_id_write" {
#   source          = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=master"
#   parameter_write = [{
#   name            = "/${var.env}/${module.eks.cluster_name}/database/master_password"
#   value           = "password1"
#   type            = "String"
#   overwrite       = "true"
#   description     = "${} ssm credentials"
#   }]

#   tags = {
#     ManagedBy = "Terraform"
#     env       = var.env
#   }
# }

# module "ssm_param_read" {
#   source         = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=master"
#   parameter_read = ["/cp/prod/app/database/master_password"]
# }
