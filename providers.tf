provider "aws" {
  default_tags {
    tags = local.aws_common_tags
  }
}
