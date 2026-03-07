################################################################################
# Data Sources
################################################################################

data "aws_vpc" "this" {
  count = var.vpc_id != null ? 1 : 0

  id = var.vpc_id
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
