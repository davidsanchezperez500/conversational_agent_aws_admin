resource "aws_cloudwatch_log_group" "s3_trail_logs" {
  name              = "/aws/cloudtrail/s3-logs"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.conversational_agent_terraform_state.arn
  tags              = local.aws_common_tags
}

resource "aws_iam_role" "cloudtrail_to_cw" {
  name               = "cloudtrail-to-cloudwatch-logs"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "cloudtrail.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudtrail_to_cw" {
  name   = "cloudtrail-to-cloudwatch-logs-policy"
  role   = aws_iam_role.cloudtrail_to_cw.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup"
      ],
      "Resource": "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/cloudtrail/s3-logs:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/cloudtrail/s3-logs:*"
    }
  ]
}
EOF
}


/* resource "aws_cloudtrail" "s3_trail_conversational_agent_terraform_state" {
  name                          = "s3-trail"
  s3_bucket_name                = aws_s3_bucket.conversational_agent_terraform_state.id
  include_global_service_events = false
  is_multi_region_trail         = false
  enable_logging                = true
  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.s3_trail_logs.arn
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_to_cw.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = false
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::${aws_s3_bucket.conversational_agent_terraform_state.id}/*"]
    }
  }
  tags = local.aws_common_tags

  depends_on = [
    aws_cloudwatch_log_group.s3_trail_logs,
    aws_iam_role.cloudtrail_to_cw,
    aws_iam_role_policy.cloudtrail_to_cw
  ]
} */

output "cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.s3_trail_logs.arn
}
# arn:aws:logs:us-east-1:853878127117:log-group:/aws/cloudtrail/s3-logs



# Logs Networking

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flow-logs"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.conversational_agent_terraform_state.arn

  tags = merge(
    local.aws_common_tags,
    {
      Name = "vpc-flow-logs"
    }
  )
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_logs" {
  name = "vpc-flow-logs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(
    local.aws_common_tags,
    {
      Name = "vpc-flow-logs-role"
    }
  )
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          aws_cloudwatch_log_group.vpc_flow_logs.arn,
          "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
        ]
      }
    ]
  })
}

# VPC Flow Log
resource "aws_flow_log" "vpc" {
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn         = aws_iam_role.vpc_flow_logs.arn
  vpc_id               = aws_vpc.main.id
  traffic_type         = "ALL"

  tags = merge(
    local.aws_common_tags,
    {
      Name = "main-vpc-flow-logs"
    }
  )
}
