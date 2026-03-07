output "producer_endpoint_service_id" {
  description = "The ID of the producer VPC Endpoint Service"
  value       = module.privatelink_producer.endpoint_service_id
}

output "producer_endpoint_service_name" {
  description = "The service name of the producer VPC Endpoint Service"
  value       = module.privatelink_producer.endpoint_service_name
}

output "consumer_endpoint_ids" {
  description = "Map of consumer endpoint IDs"
  value       = module.privatelink_consumer.endpoint_ids
}

output "consumer_endpoint_dns_entries" {
  description = "Map of consumer endpoint DNS entries"
  value       = module.privatelink_consumer.endpoint_dns_entries
}
