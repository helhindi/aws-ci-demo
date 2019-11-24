/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "aws-ci-demo"
  team_name = "admin"

  # aws_region = "eu-west-2"     # This input is deprecated from version 3.2 of this module

  # providers = {
  #   aws = "aws.london"
  # }
}

resource "kubernetes_secret" "ecr_secret" {
  metadata {
    name      = "ecr-credentials-output"
    # namespace = "default"
  }

  data {
    access_key_id     = "${module.ecr.access_key_id}"
    secret_access_key = "${module.ecr.secret_access_key}"
    repo_arn          = "${module.ecr.repo_arn}"
    repo_url          = "${module.ecr.repo_url}"
  }
}
