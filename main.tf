# Managed By : CloudDrove
# Description : This Script is used to create CloudTrail.
# Copyright @ CloudDrove. All Right Reserved.

#Module      : Labels
#Description : This terraform module is designed to generate consistent label names and tags
#              for resources. You can use terraform-labels to implement a strict naming
#              convention.
module "labels" {
  source = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.12.0"

  name        = var.name
  application = var.application
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
}

#Module      : CLOUDTRAIL
#Description : Terraform module to provision an AWS CloudTrail with encrypted S3 bucket.
#              This bucket is used to store CloudTrail logs.
resource "aws_cloudtrail" "default" {
  count = var.enabled_cloudtrail == true ? 1 : 0

  name                          = module.labels.id
  enable_logging                = var.enable_logging
  s3_bucket_name                = var.s3_bucket_name
  enable_log_file_validation    = var.enable_log_file_validation
  is_multi_region_trail         = var.is_multi_region_trail
  include_global_service_events = var.include_global_service_events
  cloud_watch_logs_role_arn     = var.cloud_watch_logs_role_arn
  cloud_watch_logs_group_arn    = format("%s:*",var.cloud_watch_logs_group_arn)
  kms_key_id                    = var.kms_key_id
  is_organization_trail         = var.is_organization_trail
  tags                          = module.labels.tags
}