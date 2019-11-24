output "cluster_name" {
  description = "EKS cluster name."
  value       = local.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "kubectl_config" {
  description = "kubectl config as generated by the module."
  value       = module.eks.kubeconfig
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks.config_map_aws_auth
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster cert."
  value       = module.eks.cluster_certificate_authority_data
}

output "region" {
  description = "AWS region"
  value       = var.region
}

# output "ecr_repository_name" {
#   description = "ECR repo name"
#   value       = module.ecr.default.ecr_repository_name
# }

# output "ecr_repository_url" {
#   description = "ECR repo URL"
#   value       = module.ecr.default.repository_url
# }

# output "ecr_registry_id" {
#   description = "ECR registry id"
#   value       = module.ecr.default.registry_id
# }

# output "ecr_arn" {
#   description = "ECR repo ARN"
#   value       = module.ecr.ecr_arn
# }
