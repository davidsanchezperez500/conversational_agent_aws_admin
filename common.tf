locals {
  aws_common_tags = {
    application = "conversational-agent"
    environment = var.environment
    cost-center = "abcd1234"
  }
}
