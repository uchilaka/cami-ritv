output "core_app_url" {
  value = fly_app.core.app_url
}

output "crm_app_url" {
  value = fly_app.crm.app_url
}

output "redis_url" {
  value     = fly_redis.cache.primary_url
  sensitive = true
}
