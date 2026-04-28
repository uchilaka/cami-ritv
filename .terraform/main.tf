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
  vm_size      = var.fly_postgres_vm_size
  cluster_size = var.fly_postgres_cluster_size
  volume_size  = var.fly_postgres_volume_size
}

resource "fly_redis" "cache" {
  name   = "${var.app_name_prefix}-redis"
  org    = var.fly_org
  region = var.fly_region
  plan   = var.fly_redis_plan
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
  database_name = "twenty_production"
  variable_name = "PG_DATABASE_URL"
}


resource "fly_volume" "crm_storage" {
  app    = fly_app.crm.name
  name   = "crm_storage"
  size   = 10
  region = var.fly_region
}

resource "fly_volume" "core_storage" {
  app    = fly_app.core.name
  name   = "core_storage"
  size   = 10
  region = var.fly_region
}
