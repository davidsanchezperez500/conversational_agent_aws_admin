resource "aws_s3_bucket" "conversational_agent_terraform_state" {
  bucket = "conversational-agent-terraform-state"
  tags   = local.aws_common_tags
}

# S3 bucket public access block configuration (recommended resource)
resource "aws_s3_bucket_public_access_block" "conversational_agent_terraform_state" {
  bucket                  = aws_s3_bucket.conversational_agent_terraform_state.id
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
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.conversational_agent_terraform_state.arn
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

resource "aws_s3_bucket_logging" "conversational_agent_terraform_state" {
  bucket = aws_s3_bucket.conversational_agent_terraform_state.id

  target_bucket = aws_s3_bucket.conversational_agent_terraform_state.id
  target_prefix = "logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "conversational_agent_terraform_state" {
  bucket = aws_s3_bucket.conversational_agent_terraform_state.id

  rule {
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    id     = "expire-logs"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    expiration {
      days = 30
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.conversational_agent_terraform_state.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailAclCheck",
      "Effect": "Allow",
      "Principal": { "Service": "cloudtrail.amazonaws.com" },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.conversational_agent_terraform_state.arn}"
    },
    {
      "Sid": "AWSCloudTrailWrite",
      "Effect": "Allow",
      "Principal": { "Service": "cloudtrail.amazonaws.com" },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.conversational_agent_terraform_state.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
  ]
}
EOF
}

