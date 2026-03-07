################################################################################
# Basic Example - VPC Endpoints for Common AWS Services
################################################################################

provider "aws" {
  region = "us-east-1"
}

module "vpc_endpoints" {
  source = "../../"

  name   = "basic-example"
  vpc_id = "vpc-0123456789abcdef0"

  create_vpc_endpoints = true

  endpoints = {
    s3 = {
      service_name = "com.amazonaws.us-east-1.s3"
      type         = "Gateway"
    }
    dynamodb = {
      service_name = "com.amazonaws.us-east-1.dynamodb"
      type         = "Gateway"
    }
    ssm = {
      service_name        = "com.amazonaws.us-east-1.ssm"
      type                = "Interface"
      subnet_ids          = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
      private_dns_enabled = true
    }
  }

  tags = {
    Environment = "dev"
    Project     = "basic-privatelink"
  }
}
