output "endpoint_service_id" {
  description = "The ID of the VPC Endpoint Service."
  value       = try(aws_vpc_endpoint_service.this[0].id, null)
}

output "endpoint_service_name" {
  description = "The service name of the VPC Endpoint Service."
  value       = try(aws_vpc_endpoint_service.this[0].service_name, null)
}

output "endpoint_service_arn" {
  description = "The ARN of the VPC Endpoint Service."
  value       = try(aws_vpc_endpoint_service.this[0].arn, null)
}

output "endpoint_service_availability_zones" {
  description = "The Availability Zones in which the service is available."
  value       = try(aws_vpc_endpoint_service.this[0].availability_zones, null)
}

output "endpoint_service_private_dns_name_configuration" {
  description = "The private DNS name configuration for the endpoint service."
  value       = try(aws_vpc_endpoint_service.this[0].private_dns_name_configuration, null)
}

output "endpoint_ids" {
  description = "A map of endpoint keys to their VPC Endpoint IDs."
  value = {
    for k, v in aws_vpc_endpoint.this : k => v.id
  }
}

output "endpoint_dns_entries" {
  description = "A map of endpoint keys to their DNS entries."
  value = {
    for k, v in aws_vpc_endpoint.this : k => v.dns_entry
  }
}

output "endpoint_arns" {
  description = "A map of endpoint keys to their ARNs."
  value = {
    for k, v in aws_vpc_endpoint.this : k => v.arn
  }
}

output "endpoint_network_interface_ids" {
  description = "A map of endpoint keys to their network interface IDs (Interface type only)."
  value = {
    for k, v in aws_vpc_endpoint.this : k => v.network_interface_ids if v.vpc_endpoint_type == "Interface"
  }
}

output "security_group_id" {
  description = "The ID of the default security group created for VPC endpoints."
  value       = try(aws_security_group.endpoint[0].id, null)
}
