variable "fly_org" {
  description = "Fly.io Organization Slug"
  type        = string
}

variable "fly_region" {
  description = "Fly.io Deployment Region"
  type        = string
  default     = "iad"
}

variable "app_name_prefix" {
  description = "Prefix for the applications"
  type        = string
  default     = "cami"
}

variable "rails_master_key" {
  description = "Rails Master Key"
  type        = string
  sensitive   = true
}

variable "gitcrypt_key_base64" {
  description = "Base64 encoded git-crypt key"
  type        = string
  sensitive   = true
}

variable "app_secret" {
  description = "Secret for Twenty CRM"
  type        = string
  sensitive   = true
}
