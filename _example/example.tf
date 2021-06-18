provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

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

# This role is used by CloudTrail to send logs to CloudWatch.
resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  name               = "cloudwatch-role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
}

# This CloudWatch Group is used for storing CloudTrail logs.
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "cloudwatch-log-group"
  retention_in_days = "180"
  kms_key_id        = module.kms_key.key_arn
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_logs" {
  statement {
    sid = "WriteCloudWatchLogs"

    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:${data.aws_partition.current.partition}:logs:eu-west-1:${data.aws_caller_identity.current.account_id}:log-group:cloudwatch-log-group:*"]
  }
}

resource "aws_iam_policy" "cloudtrail_cloudwatch_logs" {
  name   = "cloudtrail-cloudwatch-logs-policy"
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_logs.json
}

resource "aws_iam_policy_attachment" "main" {
  name       = "cloudtrail-cloudwatch-logs-policy-attachment"
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch_logs.arn
  roles      = [aws_iam_role.cloudtrail_cloudwatch_role.name]
}

module "s3_logs" {
  source  = "clouddrove/s3/aws"
  version = "0.15.0"

  name                    = "bucket-logs"
  repository              = "https://registry.terraform.io/modules/clouddrove/s3/aws/latest"
  environment             = "security"
  label_order             = ["name", "environment"]
  versioning              = true
  acl                     = "log-delivery-write"
  bucket_policy           = true
  aws_iam_policy_document = data.aws_iam_policy_document.default.json
  force_destroy           = true
}

module "kms_key" {
  source  = "clouddrove/kms/aws"
  version = "0.14.0"

  name        = "kms"
  repository  = "https://registry.terraform.io/modules/clouddrove/kms/aws/latest"
  environment = "test"
  label_order = ["name", "environment"]

  description             = "KMS key for cloudtrail"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  alias                   = "alias/cloudtrail"
  policy                  = data.aws_iam_policy_document.kms.json
}


module "cloudtrail" {
  source = "../"

  name                          = "cloudtrail"
  repository                    = "https://registry.terraform.io/modules/clouddrove/cloudtrail/aws/latest"
  environment                   = "security"
  label_order                   = ["name", "environment"]
  s3_bucket_name                = module.s3_logs.id
  enable_logging                = true
  enable_log_file_validation    = true
  include_global_service_events = true
  is_organization_trail         = false
  kms_key_id                    = module.kms_key.key_arn

  cloud_watch_logs_group_arn = aws_cloudwatch_log_group.cloudtrail.arn
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cloudwatch_role.arn

  depends_on = [module.s3_logs]
}

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
    sid    = "Allow principals in the account to decrypt log files"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
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

data "aws_iam_policy_document" "default" {
  statement {
    sid    = "cloudtrail-logs-get-bucket-acl"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::bucket-logs-security"]
  }

  statement {
    sid    = "cloudtrail-logs-put-object"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::bucket-logs-security/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}