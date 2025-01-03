// Certificate Authority to be used with PhotoAtom Frontend
resource "kubernetes_manifest" "photoatom_ca" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "${var.photoatom_ca_name}"
      "namespace" = "${var.namespace}"
      "labels" = {
        "app"       = "photoatom"
        "component" = "ca"
      }
    }
    "spec" = {
      "isCA" = true
      "subject" = {
        "organizations"       = ["photoatom"]
        "countries"           = ["India"]
        "organizationalUnits" = ["frontend"]
      }
      "commonName" = "photoatom-ca"
      "secretName" = "photoatom-ca-tls"
      "duration"   = "70128h"
      "privateKey" = {
        "algorithm" = "ECDSA"
        "size"      = 256
      }
      "issuerRef" = {
        "name"  = "${var.cluster_issuer_name}"
        "kind"  = "ClusterIssuer"
        "group" = "cert-manager.io"
      }
    }
  }
}

// Issuer for the PhotoAtom Frontend Namespace
resource "kubernetes_manifest" "photoatom_issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Issuer"
    "metadata" = {
      "name"      = "${var.photoatom_issuer_name}"
      "namespace" = "${var.namespace}"
      "labels" = {
        "app"       = "photoatom"
        "component" = "issuer"
      }
    }
    "spec" = {
      "ca" = {
        "secretName" = "photoatom-ca-tls"
      }
    }
  }

  depends_on = [kubernetes_manifest.photoatom_ca]
}

// Certificate for PhotoAtom Frontend
resource "kubernetes_manifest" "photoatom_certificate" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "${var.photoatom_certificate_name}"
      "namespace" = "${var.namespace}"
      "labels" = {
        "app"       = "photoatom"
        "component" = "certificate"
      }
    }
    "spec" = {
      "dnsNames" = [
        "${var.photoatom_domain}",
        "localhost",
        "127.0.0.1",
        "*.frontend.svc.cluster.local",
        "photoatom",
        "photoatom.frontend.svc.cluster.local",
        "*.photoatom.frontend.svc.cluster.local",
      ]
      "subject" = {
        "organizations"       = ["photoatom"]
        "countries"           = ["India"]
        "organizationalUnits" = ["frontend"]
      }
      "commonName" = "photoatom"
      "secretName" = "photoatom-tls"
      "issuerRef" = {
        "name" = "${var.photoatom_issuer_name}"
      }
    }
  }

  depends_on = [kubernetes_manifest.photoatom_issuer]
}

// Kubernetes Secret for Cloudflare Tokens
resource "kubernetes_secret" "cloudflare_token" {
  metadata {
    name      = "cloudflare-token"
    namespace = var.namespace
    labels = {
      "app"       = "photoatom"
      "component" = "secret"
    }

  }

  data = {
    cloudflare-token = var.cloudflare_token
  }

  type = "Opaque"
}

// Cloudflare Issuer for photoatom Ingress Service
resource "kubernetes_manifest" "photoatom_public_issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Issuer"
    "metadata" = {
      "name"      = "photoatom-public-issuer"
      "namespace" = var.namespace
      "labels" = {
        "app"       = "photoatom"
        "component" = "issuer"
      }
    }
    "spec" = {
      "acme" = {
        "email"  = var.cloudflare_email
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "privateKeySecretRef" = {
          "name" = "photoatom-issuer-key"
        }
        "solvers" = [
          {
            "dns01" = {
              "cloudflare" = {
                "email" = var.cloudflare_email
                "apiTokenSecretRef" = {
                  "name" = "cloudflare-token"
                  "key"  = "cloudflare-token"
                }
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [kubernetes_secret.cloudflare_token]
}

// Certificate to be used for photoatom Ingress
resource "kubernetes_manifest" "photoatom_ingress_certificate" {

  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "photoatom-ingress-certificate"
      "namespace" = var.namespace
      "labels" = {
        "app"       = "photoatom"
        "component" = "certificate"
      }
    }
    "spec" = {
      "duration"    = "2160h"
      "renewBefore" = "360h"
      "subject" = {
        "organizations"       = ["photoatom"]
        "countries"           = ["India"]
        "organizationalUnits" = ["photoatom"]
      }
      "privateKey" = {
        "algorithm" = "RSA"
        "encoding"  = "PKCS1"
        "size"      = "2048"
      }
      "dnsNames"   = ["${var.photoatom_domain}"]
      "secretName" = "photoatom-ingress-tls"
      "issuerRef" = {
        "name"  = "photoatom-public-issuer"
        "kind"  = "Issuer"
        "group" = "cert-manager.io"
      }
    }
  }

  depends_on = [kubernetes_manifest.photoatom_public_issuer]

}
