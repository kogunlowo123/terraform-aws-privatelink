variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "complete-privatelink"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "demo"
    Project     = "complete-privatelink-example"
    ManagedBy   = "terraform"
  }
}
