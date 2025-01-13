// Keycloak Variables
variable "keycloak_namespace" {
  default     = "keycloak"
  description = "Keycloak Namespace from where Ingress IP addresses are needed to be injected in pods."
}

variable "keycloak_ingress_name" {
  default     = "keycloak-ingress"
  description = "Keycloak Ingress Name whose IP are needed to be injected in pods."
}

variable "keycloak_host_name" {
  default     = "auth"
  description = "Host name to be used with Keycloak Ingress"
}

variable "photoatom_domain" {
  description = "Domain to be used for Ingress"
  default     = "photoatom.khatrivarun.xyz"
  type        = string
}

// PhotoAtom Backend Variables
variable "backend_namespace" {
  default     = "backend"
  description = "Namespace for PhotoAtom Backend"
}

variable "backend_ingress" {
  default     = "photoatom-backend-ingress"
  description = "Backend Ingress Name"
}

variable "backend_host_name" {
  default     = "backend"
  description = "Host name to be used with Backend Ingress"
}

// Secrets and Configmaps for mounting on the container
variable "namespace" {
  default     = "frontend"
  description = "Namespace to be used for deploying PhotoAtom Frontend and related resources."
}

variable "environment_variables_secrets_name" {
  default     = ["photoatom-keycloak-secrets", "photoatom-valkey-secret"]
  description = "Environment Variables to be set on the container from Secrets."
}

variable "environment_variables_configmaps_name" {
  default     = ["photoatom-backend-configuration", "photoatom-keycloak-configuration", "photoatom-valkey-configuration"]
  description = "Environment Variables to be set on the container from ConfigMaps."

}

variable "path_environment_variables" {
  default = [
    {
      name = "VALKEY_CA_CRT"
      path = "/mnt/certs/valkey/ca.crt"
    },
    {
      name = "VALKEY_TLS_CRT"
      path = "/mnt/certs/valkey/tls.crt"
    },
    {
      name = "VALKEY_TLS_KEY"
      path = "/mnt/certs/valkey/tls.key"
    },
    {
      name = "TLS_CERT"
      path = "/mnt/certs/tls/tls.crt"
    },
    {
      name = "TLS_CERT_KEY"
      path = "/mnt/certs/tls/tls.key"
    }
  ]

  description = "Paths to be used for referencing files"

}

variable "mounted_secrets_name" {
  default = [
    {
      "secretName" = "photoatom-tls"
      "mountPath"  = "/mnt/certs/tls"
    },
    {
      "secretName" = "photoatom-valkey-certificates"
      "mountPath"  = "/mnt/certs/valkey"
    },
  ]
  description = "Secrets to be mounted as part of the filesystem."
}

// Version for the artifact
variable "artifact_version" {
  description = "Artifact Version to be deployed"
  type        = string
}
