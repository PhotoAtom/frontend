// Valkey Database Configuration Details
data "kubernetes_secret" "valkey_certs" {
  metadata {
    name      = "valkey-tls"
    namespace = var.valkey_namespace
  }
}

data "kubernetes_secret" "valkey_password" {
  metadata {
    name      = "valkey"
    namespace = var.valkey_namespace
  }
}

resource "kubernetes_secret" "valkey_certificates" {
  metadata {
    name      = "photoatom-valkey-certificates"
    namespace = var.namespace
    labels = {
      app       = "frontend"
      component = "secret"
    }
  }

  data = {
    "ca.crt"  = data.kubernetes_secret.valkey_certs.data["ca.crt"]
    "tls.crt" = data.kubernetes_secret.valkey_certs.data["tls.crt"]
    "tls.key" = data.kubernetes_secret.valkey_certs.data["tls.key"]
  }

  type = "kubernetes.io/tls"
}

resource "kubernetes_secret" "valkey" {
  metadata {
    name      = var.photoatom_valkey_secret_name
    namespace = var.namespace
    labels = {
      app       = "frontend"
      component = "secret"
    }
  }

  data = {
    VALKEY_PASSWORD = data.kubernetes_secret.valkey_password.data["valkey-password"]
  }

  type = "Opaque"
}

resource "kubernetes_config_map" "valkey" {
  metadata {
    name      = var.photoatom_valkey_configuration_name
    namespace = var.namespace
    labels = {
      app       = "frontend"
      component = "configmap"
    }
  }

  data = {
    VALKEY_HOST = "valkey-node-0.valkey-headless.${var.valkey_namespace}.svc.cluster.local"
    VALKEY_PORT = 6379
  }
}

// Keycloak Configuration Details
data "kubernetes_secret" "keycloak_client_secret" {
  metadata {
    name      = "photoatom-client-secrets"
    namespace = var.keycloak_namespace
  }
}

resource "kubernetes_secret" "keycloak_client_secret" {
  metadata {
    name      = "photoatom-keycloak-secrets"
    namespace = var.namespace
    labels = {
      app       = "frontend"
      component = "secret"
    }
  }

  data = {
    KEYCLOAK_CLIENT_SECRET = data.kubernetes_secret.keycloak_client_secret.data["PHOTOATOM_FRONTEND_CLIENT_SECRET"]
  }

  type = "Opaque"
}

resource "kubernetes_config_map" "photoatom_keycloak_configuration" {
  metadata {
    name      = var.photoatom_keycloak_configuration_name
    namespace = var.namespace
    labels = {
      app       = "photoatom"
      component = "configmap"
    }
  }

  data = {
    KEYCLOAK_URL          = "https://${var.keycloak_host_name}.${var.photoatom_domain}/realms/PhotoAtom"
    KEYCLOAK_CLIENT_ID    = "frontend"
    KEYCLOAK_REDIRECT_URI = "https://${var.photoatom_domain}/login/keycloak/callback"
  }
}

// PhotoAtom Backend Configurations
resource "kubernetes_config_map" "photoatom_backend_configuration" {
  metadata {
    name      = var.photoatom_backend_configuration_name
    namespace = var.namespace
    labels = {
      app       = "frontend"
      component = "configmap"
    }
  }

  data = {
    PHOTOATOM_BACKEND_API_URL = "${var.backend_host_name}.${var.photoatom_domain}"
  }
}
