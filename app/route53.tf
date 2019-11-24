locals {
  name = "external-dns"
}

resource "aws_route53_zone" "dev" {
  name = "dev.${var.domain}"
}

resource "kubernetes_deployment" "external_dns" {
  metadata {
    name      = local.name
    namespace = var.namespace
  }

  spec {
    selector {
      match_labels = {
        app = local.name
      }
    }

    template {
      metadata {
        labels = {
          app = local.name
        }
      }

      spec {
        container {
          name  = local.name
          image = var.image
          args = concat([
            "--source=service",
            "--source=ingress",
            "--domain-filter=${aws_route53_zone.dev.name}",
            "--provider=${var.cloud_provider}",
            "--policy=upsert-only",
            "--registry=txt",
            "--txt-owner-id=${aws_route53_zone.dev.zone_id}"
          ], var.other_provider_options)
        }

        service_account_name = local.name
      }
    }

    strategy {
      type = "Recreate"
    }
  }
}
