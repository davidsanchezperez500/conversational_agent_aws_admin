provider "aws" {
  region = var.aws_region
  default_tags {
    tags = local.aws_common_tags
  }
}
