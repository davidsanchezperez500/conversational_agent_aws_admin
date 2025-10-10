resource "aws_kms_key" "conversational_agent_terraform_state" {
  description             = "KMS key for encrypting the S3 bucket used for Terraform state"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = local.aws_common_tags
  policy                  = <<POLICY
  {
    "Version": "2012-10-17",
    "Id": "default",
    "Statement": [
      {
        "Sid": "DefaultAllow",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::853878127117:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      }
    ]
  }
POLICY
}

resource "aws_kms_alias" "conversational_agent_terraform_state" {
  name          = "alias/conversational-agent-terraform-state"
  target_key_id = aws_kms_key.conversational_agent_terraform_state.key_id
}
