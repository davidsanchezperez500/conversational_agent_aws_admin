variable "environment" {
  description = "The environment for the deployment (e.g. dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}
