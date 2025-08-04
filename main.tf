
provider "aws" {}

# Random suffix (optional for name conflict avoidance)
resource "random_id" "suffix" {
  byte_length = 2
}

# MODULE: LABELS
module "labels" {
  source      = "clouddrove/labels/aws"
  version     = "1.3.0"
  name        = var.name
  repository  = var.repository
  environment = var.environment
  managedby   = var.managedby
  attributes  = var.attributes
  label_order = var.label_order
}

# CREATE S3 BUCKET (OPTIONAL)
resource "aws_s3_bucket" "cloudtrail_logs" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = var.s3_bucket_name
  tags   = module.labels.tags
}

resource "aws_s3_bucket_policy" "cloudtrail_logs_policy" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail_logs[0].id
  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy[0].json
}

data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  count = var.create_s3_bucket ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl", "s3:PutObject"]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]
  }
}

# MODULE: CLOUDTRAIL
resource "aws_cloudtrail" "default" {
  count                          = var.enabled_cloudtrail ? 1 : 0
  name                           = module.labels.id
  enable_logging                 = var.enable_logging
  s3_bucket_name                 = var.create_s3_bucket ? aws_s3_bucket.cloudtrail_logs[0].bucket : var.s3_bucket_name
  s3_key_prefix                  = var.s3_key_prefix
  enable_log_file_validation     = var.enable_log_file_validation
  is_multi_region_trail          = var.is_multi_region_trail
  include_global_service_events  = var.include_global_service_events
  cloud_watch_logs_role_arn      = var.cloud_watch_logs_role_arn
  cloud_watch_logs_group_arn     = var.cloud_watch_logs_group_arn != "" ? format("%s:*", var.cloud_watch_logs_group_arn) : ""
  kms_key_id                     = join("", aws_kms_key.cloudtrail[*].arn)
  is_organization_trail          = var.is_organization_trail
  tags                           = module.labels.tags
  sns_topic_name                 = var.sns_topic_name

  dynamic "event_selector" {
    for_each = var.event_selector ? [true] : []
    content {
      read_write_type           = var.read_write_type
      include_management_events = var.include_management_events
      dynamic "data_resource" {
        for_each = var.event_selector_data_resource ? ["true"] : []
        content {
          type   = var.data_resource_type
          values = var.data_resource_values
        }
      }
    }
  }

  dynamic "insight_selector" {
    for_each = var.insight_selector
    content {
      insight_type = insight_selector.value.insight_type
    }
  }

  lifecycle {
    ignore_changes = [event_selector]
  }

  depends_on = [aws_kms_key.cloudtrail]
}

# KMS
resource "aws_kms_key" "cloudtrail" {
  count                   = var.kms_enabled && var.enabled_cloudtrail ? 1 : 0
  description             = "A KMS key used to encrypt CloudTrail log files stored in S3."
  deletion_window_in_days = var.key_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms.json
  tags                    = module.labels.tags
}

# KMS POLICY
data "aws_iam_policy_document" "kms" {
  version = "2012-10-17"

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }
  }

  statement {
    sid    = "Allow CloudTrail to describe key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:DescribeKey"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow account to decrypt log files"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["kms:Decrypt", "kms:ReEncryptFrom"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }
  }

  statement {
    sid    = "Allow alias creation during setup"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:CreateAlias"]
    resources = ["*"]
  }
}

# IAM ROLE FOR CLOUDWATCH LOGS
data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  count              = var.enable_cloudwatch && var.enabled_cloudtrail ? 1 : 0
  name               = "${var.iam_role_name}-${random_id.suffix.hex}"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  count             = var.enable_cloudwatch && var.enabled_cloudtrail ? 1 : 0
  name              = var.cloudwatch_log_group_name
  retention_in_days = var.log_retention_days
  kms_key_id        = join("", aws_kms_key.cloudtrail[*].arn)
}

# IAM POLICY FOR CLOUDWATCH LOGS
data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_logs" {
  statement {
    sid     = "WriteCloudWatchLogs"
    effect  = "Allow"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [
      "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:cloudwatch-log-group:*"
    ]
  }
}

resource "aws_iam_policy" "cloudtrail_cloudwatch_logs" {
  count  = var.enable_cloudwatch && var.enabled_cloudtrail ? 1 : 0
  name   = "${var.iam_policy_name}-${random_id.suffix.hex}"
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_logs.json
}

resource "aws_iam_policy_attachment" "main" {
  count      = var.enable_cloudwatch && var.enabled_cloudtrail ? 1 : 0
  name       = "cloudtrail-cloudwatch-logs-policy-attachment"
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch_logs[0].arn
  roles      = [aws_iam_role.cloudtrail_cloudwatch_role[0].name]
}
