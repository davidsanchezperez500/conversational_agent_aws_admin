resource "aws_s3_bucket" "conversational_agent_terraform_state" {
  bucket = "conversational-agent-terraform-state"
  tags   = local.aws_common_tags
}
# S3 bucket public access block configuration (recommended resource)
resource "aws_s3_bucket_public_access_block" "conversational_agent_terraform_state" {
  bucket = aws_s3_bucket.conversational_agent_terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# S3 bucket server-side encryption configuration (recommended resource)
resource "aws_s3_bucket_server_side_encryption_configuration" "conversational_agent_terraform_state" {
  bucket = aws_s3_bucket.conversational_agent_terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "conversational_agent_terraform_state" {
  bucket = aws_s3_bucket.conversational_agent_terraform_state.id

  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Disabled"
  }
}
