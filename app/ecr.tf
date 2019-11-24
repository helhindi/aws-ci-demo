module "ecr" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "ci"
  team_name = "future-admin"
}

# resource "kubernetes_secret" "ecr_secret" {
#   metadata {
#     name      = "ecr-credentials"
#     namespace = "default"
#   }

#   data = {
#     access_key_id     = module.ecr.access_key_id
#     secret_access_key = module.ecr.secret_access_key
#     repo_arn          = module.ecr.repo_arn
#     repo_url          = module.ecr.repo_url
#     }

#   type = "kubernetes.io/basic-auth"
# }

