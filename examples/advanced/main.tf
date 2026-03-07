################################################################################
# Advanced Example - VPC Endpoint Service (Producer) with PrivateLink
################################################################################

provider "aws" {
  region = "us-east-1"
}

################################################################################
# Endpoint Service Producer
################################################################################

module "endpoint_service" {
  source = "../../"

  name   = "advanced-producer"
  vpc_id = "vpc-producer0123456789"

  # Producer configuration
  create_endpoint_service    = true
  network_load_balancer_arns = ["arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/net/my-nlb/1234567890abcdef"]
  acceptance_required        = true
  private_dns_name           = "api.example.com"

  allowed_principals = [
    "arn:aws:iam::111111111111:root",
    "arn:aws:iam::222222222222:root",
  ]

  # No consumer endpoints in this module instance
  create_vpc_endpoints = false

  tags = {
    Environment = "production"
    Project     = "advanced-privatelink"
    Role        = "producer"
  }
}

################################################################################
# Endpoint Consumer (connecting to the producer service)
################################################################################

module "endpoint_consumer" {
  source = "../../"

  name   = "advanced-consumer"
  vpc_id = "vpc-consumer0123456789"

  create_endpoint_service = false
  create_vpc_endpoints    = true

  endpoints = {
    custom_service = {
      service_name        = module.endpoint_service.endpoint_service_name
      type                = "Interface"
      subnet_ids          = ["subnet-consumer01234", "subnet-consumer56789"]
      security_group_ids  = ["sg-consumer0123456789"]
      private_dns_enabled = false
    }
  }

  tags = {
    Environment = "production"
    Project     = "advanced-privatelink"
    Role        = "consumer"
  }
}
