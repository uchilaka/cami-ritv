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

variable "fly_postgres_vm_size" {
  description = "Fly.io Postgres VM Size"
  type        = string
  default     = "shared-cpu-1x"
}

variable "fly_postgres_cluster_size" {
  description = "Number of Postgres instances"
  type        = number
  default     = 1
}

variable "fly_postgres_volume_size" {
  description = "Size of Postgres volume in GB"
  type        = number
  default     = 10
}

variable "fly_redis_plan" {
  description = "Fly.io Redis Plan"
  type        = string
  default     = "free"
}

variable "tf_state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
  sensitive   = true
}

variable "fly_aws_endpoint_url_s3" {
  description = "Custom AWS S3 Endpoint URL for Fly.io (Tigris)"
  type        = string
  default     = "https://fly.storage.tigris.dev"
}
