terraform {
  required_version = ">= 1.7.0"
}

module "test" {
  source = "../"

  name   = "test-privatelink"
  vpc_id = "vpc-0123456789abcdef0"

  create_vpc_endpoints = true

  endpoints = {
    s3 = {
      service_name = "com.amazonaws.us-east-1.s3"
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
    Environment = "test"
    Module      = "terraform-aws-privatelink"
  }
}
