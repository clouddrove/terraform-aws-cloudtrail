module "lables" {
  source      = "git::https://github.com/clouddrove/terraform-lables.git?ref=tags/0.11.0"
  name        = "${var.name}"
  application = "${var.application}"
  environment = "${var.environment}"
}

resource "aws_cloudtrail" "default" {
  name                          = "${module.lables.id}"
  enable_logging                = "${var.enable_logging}"
  s3_bucket_name                = "${var.s3_bucket_name}"
  enable_log_file_validation    = "${var.enable_log_file_validation}"
  is_multi_region_trail         = "${var.is_multi_region_trail}"
  include_global_service_events = "${var.include_global_service_events}"
  cloud_watch_logs_role_arn     = "${var.cloud_watch_logs_role_arn}"
  cloud_watch_logs_group_arn    = "${var.cloud_watch_logs_group_arn}"
  tags                          = "${module.lables.tags}"
  event_selector                = "${var.event_selector}"
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
      "arn:aws:s3:::${module.lables.id}",
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
      "arn:aws:s3:::${module.lables.id}/*",
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
