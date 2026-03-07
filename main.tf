################################################################################
# VPC Endpoint Service (Producer Side)
################################################################################

resource "aws_vpc_endpoint_service" "this" {
  count = var.create_endpoint_service ? 1 : 0

  acceptance_required        = var.acceptance_required
  network_load_balancer_arns = length(var.network_load_balancer_arns) > 0 ? var.network_load_balancer_arns : null
  gateway_load_balancer_arns = length(var.gateway_load_balancer_arns) > 0 ? var.gateway_load_balancer_arns : null
  private_dns_name           = var.private_dns_name

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-endpoint-service"
    }
  )
}

################################################################################
# Allowed Principals for Endpoint Service
################################################################################

resource "aws_vpc_endpoint_service_allowed_principal" "this" {
  for_each = var.create_endpoint_service ? toset(var.allowed_principals) : toset([])

  vpc_endpoint_service_id = aws_vpc_endpoint_service.this[0].id
  principal_arn           = each.value
}

################################################################################
# VPC Endpoint Connection Accepter
################################################################################

resource "aws_vpc_endpoint_connection_accepter" "this" {
  for_each = var.create_endpoint_service && var.acceptance_required ? {
    for k, v in var.endpoints : k => v if var.create_vpc_endpoints
  } : {}

  vpc_endpoint_service_id = aws_vpc_endpoint_service.this[0].id
  vpc_endpoint_id         = aws_vpc_endpoint.this[each.key].id
}

################################################################################
# Default Security Group for Interface Endpoints
################################################################################

resource "aws_security_group" "endpoint" {
  count = local.create_default_sg ? 1 : 0

  name        = "${var.name}-vpc-endpoint-sg"
  description = "Security group for VPC endpoints managed by ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = data.aws_vpc.this[0].cidr_block_associations[*].cidr_block
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-vpc-endpoint-sg"
    }
  )
}

################################################################################
# VPC Endpoints (Consumer Side)
################################################################################

resource "aws_vpc_endpoint" "this" {
  for_each = var.create_vpc_endpoints ? var.endpoints : {}

  vpc_id            = var.vpc_id
  service_name      = each.value.service_name
  vpc_endpoint_type = each.value.type

  # Interface endpoint configuration
  subnet_ids = each.value.type == "Interface" ? each.value.subnet_ids : null

  security_group_ids = each.value.type == "Interface" ? (
    length(each.value.security_group_ids) > 0
    ? each.value.security_group_ids
    : (local.create_default_sg ? [aws_security_group.endpoint[0].id] : [])
  ) : null

  private_dns_enabled = each.value.type == "Interface" ? each.value.private_dns_enabled : null

  # Gateway endpoint configuration uses route_table_ids via separate association

  policy = each.value.policy

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-${each.key}"
    }
  )
}

################################################################################
# VPC Endpoint Policy (standalone resource for additional policy management)
################################################################################

resource "aws_vpc_endpoint_policy" "this" {
  for_each = {
    for k, v in var.endpoints : k => v
    if var.create_vpc_endpoints && v.policy != null
  }

  vpc_endpoint_id = aws_vpc_endpoint.this[each.key].id
  policy          = each.value.policy
}
