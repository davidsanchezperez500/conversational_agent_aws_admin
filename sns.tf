resource "aws_sns_topic" "s3_conversational_agent_terraform_state_notifications" {
  name              = "s3-conversational-agent-terraform-state-notifications"
  kms_master_key_id = aws_kms_key.conversational_agent_terraform_state.arn
  tags              = local.aws_common_tags
}

resource "aws_s3_bucket_notification" "s3_conversational_agent_terraform_state_notifications" {
  bucket = aws_s3_bucket.conversational_agent_terraform_state.id

  topic {
    topic_arn     = aws_sns_topic.s3_conversational_agent_terraform_state_notifications.arn
    events        = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_prefix = "logs/"
  }

  depends_on = [aws_sns_topic.s3_conversational_agent_terraform_state_notifications]
}

resource "aws_sns_topic_policy" "conversational_agent_terraform_state_notifications" {
  arn    = aws_sns_topic.s3_conversational_agent_terraform_state_notifications.arn
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "s3.amazonaws.com" },
      "Action": "sns:Publish",
      "Resource": "${aws_sns_topic.s3_conversational_agent_terraform_state_notifications.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_s3_bucket.conversational_agent_terraform_state.arn}"
        }
      }
    }
  ]
}
EOF
}
