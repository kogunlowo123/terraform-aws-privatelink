################################################################################
# Complete Example - Full PrivateLink Setup with Producer, Consumer, and
# Multiple AWS Service Endpoints
################################################################################

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

################################################################################
# VPC for Producer
################################################################################

resource "aws_vpc" "producer" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-producer-vpc"
  }
}

resource "aws_subnet" "producer" {
  count = 2

  vpc_id            = aws_vpc.producer.id
  cidr_block        = cidrsubnet(aws_vpc.producer.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.name}-producer-subnet-${count.index}"
  }
}

################################################################################
# VPC for Consumer
################################################################################

resource "aws_vpc" "consumer" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-consumer-vpc"
  }
}

resource "aws_subnet" "consumer" {
  count = 2

  vpc_id            = aws_vpc.consumer.id
  cidr_block        = cidrsubnet(aws_vpc.consumer.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.name}-consumer-subnet-${count.index}"
  }
}

################################################################################
# Network Load Balancer (for Endpoint Service)
################################################################################

resource "aws_lb" "producer" {
  name               = "${var.name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = aws_subnet.producer[*].id

  tags = {
    Name = "${var.name}-producer-nlb"
  }
}

resource "aws_lb_target_group" "producer" {
  name     = "${var.name}-tg"
  port     = 443
  protocol = "TCP"
  vpc_id   = aws_vpc.producer.id

  health_check {
    protocol = "TCP"
    port     = 443
  }
}

resource "aws_lb_listener" "producer" {
  load_balancer_arn = aws_lb.producer.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.producer.arn
  }
}

################################################################################
# Security Group for Consumer Endpoints
################################################################################

resource "aws_security_group" "consumer_endpoint" {
  name        = "${var.name}-consumer-endpoint-sg"
  description = "Security group for consumer VPC endpoints"
  vpc_id      = aws_vpc.consumer.id

  ingress {
    description = "Allow HTTPS from consumer VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.consumer.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-consumer-endpoint-sg"
  }
}

################################################################################
# PrivateLink Producer (Endpoint Service)
################################################################################

module "privatelink_producer" {
  source = "../../"

  name   = "${var.name}-producer"
  vpc_id = aws_vpc.producer.id

  create_endpoint_service    = true
  network_load_balancer_arns = [aws_lb.producer.arn]
  acceptance_required        = true

  allowed_principals = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]

  create_vpc_endpoints = false

  tags = var.tags
}

data "aws_caller_identity" "current" {}

################################################################################
# PrivateLink Consumer (VPC Endpoints)
################################################################################

module "privatelink_consumer" {
  source = "../../"

  name   = "${var.name}-consumer"
  vpc_id = aws_vpc.consumer.id

  create_endpoint_service = false
  create_vpc_endpoints    = true

  endpoints = {
    # Connect to the custom producer service via PrivateLink
    custom_service = {
      service_name        = module.privatelink_producer.endpoint_service_name
      type                = "Interface"
      subnet_ids          = aws_subnet.consumer[*].id
      security_group_ids  = [aws_security_group.consumer_endpoint.id]
      private_dns_enabled = false
    }

    # AWS service endpoints for private access
    s3 = {
      service_name = "com.amazonaws.${var.region}.s3"
      type         = "Gateway"
    }

    ssm = {
      service_name        = "com.amazonaws.${var.region}.ssm"
      type                = "Interface"
      subnet_ids          = aws_subnet.consumer[*].id
      security_group_ids  = [aws_security_group.consumer_endpoint.id]
      private_dns_enabled = true
    }

    ssmmessages = {
      service_name        = "com.amazonaws.${var.region}.ssmmessages"
      type                = "Interface"
      subnet_ids          = aws_subnet.consumer[*].id
      security_group_ids  = [aws_security_group.consumer_endpoint.id]
      private_dns_enabled = true
    }

    ec2messages = {
      service_name        = "com.amazonaws.${var.region}.ec2messages"
      type                = "Interface"
      subnet_ids          = aws_subnet.consumer[*].id
      security_group_ids  = [aws_security_group.consumer_endpoint.id]
      private_dns_enabled = true
    }

    kms = {
      service_name        = "com.amazonaws.${var.region}.kms"
      type                = "Interface"
      subnet_ids          = aws_subnet.consumer[*].id
      security_group_ids  = [aws_security_group.consumer_endpoint.id]
      private_dns_enabled = true
      policy              = data.aws_iam_policy_document.kms_endpoint_policy.json
    }
  }

  tags = var.tags
}

################################################################################
# Endpoint Policy for KMS
################################################################################

data "aws_iam_policy_document" "kms_endpoint_policy" {
  statement {
    sid       = "AllowKMSAccess"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}
