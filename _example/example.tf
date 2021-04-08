provider "aws" {
  region = "eu-west-1"
}

module "s3_logs" {
  source  = "clouddrove/s3/aws"
  version = "0.14.0"

  name                    = "bucket-logs"
  repository              = "https://registry.terraform.io/modules/clouddrove/s3/aws/latest"
  environment             = "security"
  label_order             = ["name", "environment"]
  versioning              = true
  acl                     = "log-delivery-write"
  bucket_enabled          = true
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
  is_multi_region_trail         = false
  is_organization_trail         = false
  kms_key_id                    = module.kms_key.key_arn
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
      values   = ["arn:aws:cloudtrail:*:XXXXXXXXXXXX:trail/*"]
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
      values = [
      "XXXXXXXXXXXX"]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:XXXXXXXXXXXX:trail/*"]
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
    sid = "AWSCloudTrailAclCheck"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      "arn:aws:s3:::security-bucket-log-clouddrove",
    ]
  }

  statement {
    sid = "AWSCloudTrailWrite"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::security-bucket-log-clouddrove/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control",
      ]
    }
  }
}
