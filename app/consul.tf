resource "helm_release" "consul" {
  name      = var.name
  chart     = "${path.module}/consul-helm"
  namespace = var.namespace

  set {
    name  = "server.replicas"
    value = var.replicas
  }

  set {
    name  = "server.bootstrapExpect"
    value = var.replicas
  }

  set {
    name  = "server.connect"
    value = true
  }

  provisioner "local-exec" {
    command = "helm test ${var.name}"
  }
}
