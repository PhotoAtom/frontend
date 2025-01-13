// Keycloak and Frontend Ingress Reference
data "kubernetes_ingress_v1" "keycloak_ingress" {
  metadata {
    name      = var.keycloak_ingress_name
    namespace = var.keycloak_namespace
  }
}

data "kubernetes_ingress_v1" "backend_ingress" {
  metadata {
    name      = var.backend_ingress
    namespace = var.backend_namespace
  }
}
// Deployment Object for PhotoAtom Frontend
resource "kubernetes_deployment" "frontend_deployment" {
  metadata {
    name      = "frontend-deployment"
    namespace = var.namespace

    labels = {
      app       = "photoatom"
      component = "deployment"
    }
  }

  spec {

    // Number of replicas to be provisioned
    replicas = 1

    // Selector for pods to be included in deployment
    selector {
      match_labels = {
        app       = "photoatom"
        component = "pod"
      }
    }

    // Blue-Green Deployment Strategy
    strategy {
      rolling_update {
        max_surge       = 1
        max_unavailable = 0
      }
    }

    template {
      metadata {
        labels = {
          app       = "photoatom"
          component = "pod"
        }
      }

      spec {

        // Injecting Keycloak and Backend Ingress IP Addresses inside the pods
        dynamic "host_aliases" {
          for_each = data.kubernetes_ingress_v1.keycloak_ingress.status.0.load_balancer.0.ingress
          content {
            hostnames = ["${var.keycloak_host_name}.${var.photoatom_domain}"]
            ip        = host_aliases.value["ip"]
          }
        }

        dynamic "host_aliases" {
          for_each = data.kubernetes_ingress_v1.backend_ingress.status.0.load_balancer.0.ingress
          content {
            hostnames = ["${var.backend_host_name}.${var.photoatom_domain}"]
            ip        = host_aliases.value["ip"]
          }
        }

        container {

          name  = "backend"
          image = "vhkhatri/photoatom_frontend:${var.artifact_version}"

          // Port mappings for the backend
          port {
            container_port = 3000
            protocol       = "TCP"
            name           = "frontend-port"
          }

          // Resource limits for the pods
          resources {
            requests = {
              "cpu"    = "100m"
              "memory" = "250Mi"
            }
            limits = {
              "cpu"    = "500m"
              "memory" = "500Mi"
            }
          }

          // Probes for liveness, startup and readiness
          # liveness_probe {
          #   exec {
          #     command = ["curl", "--cacert", "/mnt/certs/tls/ca.crt", "https://localhost:8080/actuator/health"]
          #   }
          #
          #   initial_delay_seconds = 30
          #   period_seconds        = 3
          # }
          #
          # readiness_probe {
          #   exec {
          #     command = ["curl", "--cacert", "/mnt/certs/tls/ca.crt", "https://localhost:8080/actuator/health"]
          #   }
          #
          #   initial_delay_seconds = 30
          #   period_seconds        = 3
          # }
          #
          # startup_probe {
          #   exec {
          #     command = ["curl", "--cacert", "/mnt/certs/tls/ca.crt", "https://localhost:8080/actuator/health"]
          #   }
          #
          #   initial_delay_seconds = 30
          #   period_seconds        = 3
          # }

          // Environment Variables for the pod
          // For all sources including secrets
          // and configmaps
          dynamic "env" {
            for_each = var.path_environment_variables
            content {
              name  = env.value["name"]
              value = env.value["path"]
            }
          }

          dynamic "env_from" {
            for_each = var.environment_variables_secrets_name
            content {
              secret_ref {
                name = env_from.value
              }
            }
          }

          dynamic "env_from" {
            for_each = var.environment_variables_configmaps_name
            content {
              config_map_ref {
                name = env_from.value
              }
            }
          }

          // Mounting secrets as volumes for all certificates
          dynamic "volume_mount" {
            for_each = var.mounted_secrets_name
            content {
              name       = volume_mount.value["secretName"]
              mount_path = volume_mount.value["mountPath"]
              read_only  = true
            }
          }
        }

        dynamic "volume" {
          for_each = var.mounted_secrets_name
          content {
            name = volume.value["secretName"]
            secret {
              secret_name = volume.value["secretName"]
            }
          }
        }

      }
    }
  }
}

// Service Object for PhotoAtom Frontend
resource "kubernetes_service" "frontend_service" {
  metadata {
    name      = "photoatom"
    namespace = var.namespace
    labels = {
      app       = "photoatom"
      component = "service"
    }
  }

  spec {

    selector = {
      app       = "photoatom"
      component = "pod"
    }

    session_affinity = "ClientIP"
    port {
      port        = "8443"
      target_port = "frontend-port"
    }

    type = "ClusterIP"
  }

}

// Ingress Object for PhotoAtom Frontend
resource "kubernetes_ingress_v1" "frontend_ingress" {
  metadata {
    name      = "photoatom-frontend-ingress"
    namespace = var.namespace
    labels = {
      app       = "frontend"
      component = "ingress"
    }
    annotations = {
      "nginx.ingress.kubernetes.io/backend-protocol" : "HTTP"
      "nginx.ingress.kubernetes.io/rewrite-target" : "/"
      "nginx.ingress.kubernetes.io/proxy-body-size" : 0
    }
  }

  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = ["${var.photoatom_domain}"]
      secret_name = "photoatom-ingress-tls"
    }
    rule {
      host = var.photoatom_domain
      http {
        path {
          path = "/"
          backend {
            service {
              name = "photoatom"
              port {
                number = 8443
              }
            }
          }
        }
      }
    }
  }
}
