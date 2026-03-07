################################################################################
# General
################################################################################

variable "name" {
  description = "Name prefix for all resources created by this module"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC in which to create resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# VPC Endpoint Service (Producer)
################################################################################

variable "create_endpoint_service" {
  description = "Whether to create a VPC Endpoint Service (producer side)"
  type        = bool
  default     = false
}

variable "network_load_balancer_arns" {
  description = "List of Network Load Balancer ARNs to associate with the endpoint service"
  type        = list(string)
  default     = []
}

variable "gateway_load_balancer_arns" {
  description = "List of Gateway Load Balancer ARNs to associate with the endpoint service"
  type        = list(string)
  default     = []
}

variable "acceptance_required" {
  description = "Whether or not VPC endpoint connection requests to the service must be accepted by the service owner"
  type        = bool
  default     = true
}

variable "allowed_principals" {
  description = "List of ARNs of principals allowed to discover and connect to the endpoint service"
  type        = list(string)
  default     = []
}

variable "private_dns_name" {
  description = "The private DNS name for the endpoint service. Requires verification"
  type        = string
  default     = null
}

################################################################################
# VPC Endpoints (Consumer)
################################################################################

variable "create_vpc_endpoints" {
  description = "Whether to create VPC endpoints (consumer side)"
  type        = bool
  default     = true
}

variable "endpoints" {
  description = <<-EOT
    A map of VPC endpoint configurations. Each key is an endpoint identifier and the value is an object with:
      - service_name:        The service name for the endpoint (e.g., com.amazonaws.us-east-1.s3)
      - type:                The type of endpoint - Interface or Gateway
      - subnet_ids:          (Optional) List of subnet IDs for Interface endpoints
      - security_group_ids:  (Optional) List of security group IDs for Interface endpoints
      - private_dns_enabled: (Optional) Whether to enable private DNS for the endpoint
      - policy:              (Optional) IAM policy document in JSON to attach to the endpoint
  EOT
  type = map(object({
    service_name        = string
    type                = optional(string, "Interface")
    subnet_ids          = optional(list(string), [])
    security_group_ids  = optional(list(string), [])
    private_dns_enabled = optional(bool, false)
    policy              = optional(string, null)
  }))
  default = {}
}
