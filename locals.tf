locals {
  # Separate endpoints by type for conditional resource creation
  interface_endpoints = {
    for k, v in var.endpoints : k => v if v.type == "Interface"
  }

  gateway_endpoints = {
    for k, v in var.endpoints : k => v if v.type == "Gateway"
  }

  # Determine which endpoints need the module-managed security group
  endpoints_needing_sg = {
    for k, v in local.interface_endpoints : k => v if length(v.security_group_ids) == 0
  }

  # Create a flag indicating whether we need to create a default security group
  create_default_sg = var.create_vpc_endpoints && length(local.endpoints_needing_sg) > 0

  # Common tags applied to all resources
  common_tags = merge(
    var.tags,
    {
      "ManagedBy" = "terraform"
      "Module"    = "terraform-aws-privatelink"
    }
  )
}
