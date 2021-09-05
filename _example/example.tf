provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}


module "s3_logs" {
  source  = "clouddrove/s3/aws"
  version = "0.15.0"

  name                         = "bucket-logs"
  environment                  = "security"
  label_order                  = ["name", "environment"]
  versioning                   = true
  acl                          = "log-delivery-write"
  bucket_policy                = true
  aws_iam_policy_document      = data.aws_iam_policy_document.default.json
  lifecycle_expiration_enabled = true
  lifecycle_days_to_expiration = 10
  force_destroy                = true
}



module "cloudtrail" {
  source = "../"

  name                          = "cloudtrail"
  environment                   = "security"
  label_order                   = ["name", "environment"]
  s3_bucket_name                = module.s3_logs.id
  enable_logging                = true
  enable_log_file_validation    = true
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
