output "endpoint_service_id" {
  description = "The ID of the VPC Endpoint Service"
  value       = module.endpoint_service.endpoint_service_id
}

output "endpoint_service_name" {
  description = "The service name of the VPC Endpoint Service"
  value       = module.endpoint_service.endpoint_service_name
}

output "consumer_endpoint_ids" {
  description = "Map of consumer endpoint IDs"
  value       = module.endpoint_consumer.endpoint_ids
}

output "consumer_endpoint_dns_entries" {
  description = "Map of consumer endpoint DNS entries"
  value       = module.endpoint_consumer.endpoint_dns_entries
}
