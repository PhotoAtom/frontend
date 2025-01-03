variable "namespace" {
  default     = "backend"
  description = "Namespace to be used for deploying PhotoAtom Backend and related resources."
}

// Valkey Variables
variable "valkey_namespace" {
  default     = "valkey"
  description = "Namespace to be used for deploying Valkey Cluster and related resources."
}

variable "photoatom_valkey_secret_name" {
  default     = "photoatom-valkey-secret"
  description = "Valkey Credentials Secret Name for PhotoAtom"
}

variable "photoatom_valkey_configuration_name" {
  default     = "photoatom-valkey-configuration"
  description = "Valkey Configuration Name for PhotoAtom"
}

// Keycloak Variables
variable "keycloak_namespace" {
  default     = "keycloak"
  description = "Keycloak Namespace Name"
}

variable "keycloak_host_name" {
  default     = "auth"
  description = "Host name to be used with Keycloak Ingress"
}

variable "photoatom_domain" {
  description = "Domain to be used for Ingress"
  default     = ""
  type        = string
}

variable "photoatom_keycloak_configuration_name" {
  default     = "photoatom-keycloak-configuration"
  description = "PhotoAtom Configuration Name for PhotoAtom"
}

// PhotoAtom Backend Variables
variable "backend_host_name" {
  default     = "backend"
  description = "Host name to be used with PhotoAtom Backend Ingress"
}

variable "photoatom_backend_configuration_name" {
  default     = "photoatom-backend-configuration"
  description = "PhotoAtom Backend Configuration Name for PhotoAtom"
}
