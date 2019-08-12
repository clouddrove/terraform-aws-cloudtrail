# terraform-aws-cloudtrail 

## Usage

```hcl
module "cloudtrail" {
  source                        = "git::https://github.com/clouddrove/terraform-aws-cloudtrail.git"
  name                          = "cloudtrail"
  organization                  = "cd"
  environment                   = "security"
  enable_log_file_validation    = "true"
  include_global_service_events = "true"
  is_multi_region_trail         = "false"
  enable_logging                = "true"
  s3_bucket_name                = "cloudtrail-logs-bucket"
}
```

```hcl
module "cloudtrail" {
  source                        = "git::https://github.com/clouddrove/terraform-aws-cloudtrail.git"
  name                          = "cloudtrail"
  organization                  = "cd"
  environment                   = "security"
  enable_log_file_validation    = "true"
  include_global_service_events = "true"
  is_multi_region_trail         = "false"
  enable_logging                = "true"
  s3_bucket_name                = "${module.cloudtrail_s3_bucket.bucket_id}"
}

module "cloudtrail_s3_bucket" {
  source    = "git::https://github.com/clouddrove/terraform-aws-cloudtrail-s3-bucket.git"
  name            = "cloudtrail"
  organization    = "cd"
  environment     = "security"
  region          = "us-east-1"
}
```

For a complete example, see [examples/complete](examples/complete).


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attributes | Additional attributes (e.g. `logs`) | list | `<list>` | no |
| cloud_watch_logs_group_arn | Specifies a log group name using an Amazon Resource Name (ARN), that represents the log group to which CloudTrail logs will be delivered | string | `` | no |
| cloud_watch_logs_role_arn | Specifies the role for the CloudWatch Logs endpoint to assume to write to a user’s log group | string | `` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | string | `-` | no |
| enable_log_file_validation | Specifies whether log file integrity validation is enabled. Creates signed digest for validated contents of logs | string | `true` | no |
| enable_logging | Enable logging for the trail | string | `true` | no |
| event_selector | Specifies an event selector for enabling data event logging, It needs to be a list of map values. See: https://www.terraform.io/docs/providers/aws/r/cloudtrail.html for details on this map variable | list | `<list>` | no |
| include_global_service_events | Specifies whether the trail is publishing events from global services such as IAM to the log files | string | `false` | no |
| is_multi_region_trail | Specifies whether the trail is created in the current region or in all regions | string | `false` | no |
| kms_key_id | Specifies the KMS key ARN to use to encrypt the logs delivered by CloudTrail | string | `` | no |
| name | Name  (e.g. `app` or `cluster`) | string | - | yes |
| namespace | Namespace (e.g. `cd` or `clouddrove`) | string | - | yes |
| s3_bucket_name | S3 bucket name for CloudTrail logs | string | - | yes |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | - | yes |
| tags | Additional tags (e.g. map('BusinessUnit`,`XYZ`) | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudtrail_arn | The Amazon Resource Name of the trail |
| cloudtrail_home_region | The region in which the trail was created |
| cloudtrail_id | The name of the trail |


## 👬 Contribution
- Open pull request with improvements
- Discuss ideas in issues

- Reach out with any feedback [![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/anmol_nagpal.svg?style=social&label=Follow%20%40anmol_nagpal)](https://twitter.com/anmol_nagpal)
