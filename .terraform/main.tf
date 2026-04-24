resource "fly_app" "core" {
  name     = "${var.app_name_prefix}-core"
  org_slug = var.fly_org
}

resource "fly_app" "crm" {
  name     = "${var.app_name_prefix}-crm"
  org_slug = var.fly_org
}

resource "fly_postgres_cluster" "db" {
  name         = "${var.app_name_prefix}-postgres"
  org          = var.fly_org
  region       = var.fly_region
  vm_size      = "shared-cpu-1x"
  cluster_size = 1
  volume_size  = 10
}

resource "fly_redis" "cache" {
  name   = "${var.app_name_prefix}-redis"
  org    = var.fly_org
  region = var.fly_region
  plan   = "free"
}

# Core DB Attachment
resource "fly_postgres_attachment" "core_db" {
  app           = fly_app.core.name
  postgres_app  = fly_postgres_cluster.db.name
  database_name = "cami_production"
  variable_name = "DATABASE_URL"
}

# CRM DB Attachment
resource "fly_postgres_attachment" "crm_db" {
  app           = fly_app.crm.name
  postgres_app  = fly_postgres_cluster.db.name
  database_name = "twenty"
  variable_name = "PG_DATABASE_URL"
}

# Core Secrets
resource "fly_secret" "core_rails_master_key" {
  app   = fly_app.core.name
  key   = "RAILS_MASTER_KEY"
  value = var.rails_master_key
}

resource "fly_secret" "core_redis_url" {
  app   = fly_app.core.name
  key   = "REDIS_URL"
  value = fly_redis.cache.primary_url
}

# CRM Secrets
resource "fly_secret" "crm_app_secret" {
  app   = fly_app.crm.name
  key   = "APP_SECRET"
  value = var.app_secret
}

resource "fly_secret" "crm_redis_url" {
  app   = fly_app.crm.name
  key   = "REDIS_URL"
  value = fly_redis.cache.primary_url
}
