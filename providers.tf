
provider "aws" {
  region  = var.region
  profile = "personal"

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = false
}

provider "kubernetes" {
  host                        = module.eks.cluster_endpoint
  cluster_ca_certificate      = module.eks.cluster_certificate_authority_data
  load_config_file            = false
}

# provider "helm" {
#   version        = "~> 0.9"
#   install_tiller = true
# }
