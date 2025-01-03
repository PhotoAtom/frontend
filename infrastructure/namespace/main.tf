resource "kubernetes_namespace" "frontend" {
  metadata {
    name = var.namespace
    labels = {
      app       = "frontend"
      component = "namespace"
    }
  }
}
