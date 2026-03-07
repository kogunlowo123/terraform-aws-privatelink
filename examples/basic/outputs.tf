output "endpoint_ids" {
  description = "Map of endpoint IDs"
  value       = module.vpc_endpoints.endpoint_ids
}

output "endpoint_dns_entries" {
  description = "Map of endpoint DNS entries"
  value       = module.vpc_endpoints.endpoint_dns_entries
}
