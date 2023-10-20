provider "aws" {
  region = local.region
}
locals {
  region      = "eu-west-1"
  name        = "bucket-logs"
  environment = "security"
}
module "s3_logs" {
  source  = "clouddrove/s3/aws"
  version = "2.0.0"

  name                    = "${local.name}-bucket-logs"
  environment             = local.environment
  versioning              = true
  acl                     = "log-delivery-write"
  bucket_policy           = true
  aws_iam_policy_document = data.aws_iam_policy_document.default.json
  force_destroy           = true
}

module "cloudtrail" {
  source = "../"

  name                          = "${local.name}-cloudtrail"
  environment                   = local.environment
  s3_bucket_name                = module.s3_logs.id
  include_global_service_events = true
  is_organization_trail         = false
  log_retention_days            = 90
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
    resources = ["arn:aws:s3:::${module.s3_logs.id}"]
  }

  statement {
    sid    = "cloudtrail-logs-put-object"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${module.s3_logs.id}/AWSLogs/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}