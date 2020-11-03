#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "application" {
  type        = string
  default     = ""
  description = "Application (e.g. `cd` or `clouddrove`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "managedby" {
  type        = string
  default     = "anmol@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'."
}

#Module      : CLOUDTRAIL
#Description : Terraform VPC module variables.
variable "enabled_cloudtrail" {
  type        = bool
  default     = true
  description = "If true, deploy the resources for the module."
}

variable "enable_log_file_validation" {
  type        = bool
  default     = true
  description = "Specifies whether log file integrity validation is enabled. Creates signed digest for validated contents of logs."
}

variable "is_multi_region_trail" {
  type        = bool
  default     = false
  description = "Specifies whether the trail is created in the current region or in all regions."
}

variable "include_global_service_events" {
  type        = bool
  default     = false
  description = "Specifies whether the trail is publishing events from global services such as IAM to the log files."
}

variable "enable_logging" {
  type        = bool
  default     = true
  description = "Enable logging for the trail."
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name for CloudTrail log."
}

variable "cloud_watch_logs_role_arn" {
  type        = string
  default     = ""
  description = "Specifies the role for the CloudWatch Logs endpoint to assume to write to a user’s log group."
}

variable "cloud_watch_logs_group_arn" {
  type        = string
  default     = ""
  description = "Specifies a log group name using an Amazon Resource Name (ARN), that represents the log group to which CloudTrail logs will be delivered."
}

variable "event_selector" {
  type        = bool
  default     = true
  description = "Specifies an event selector for enabling data event logging. Fields documented below. Please note the CloudTrail limits when configuring these."
}

variable "read_write_type" {
  type        = string
  default     = "All"
  description = "Specify if you want your trail to log read-only events, write-only events, or all. By default, the value is All."
}

variable "include_management_events" {
  type        = bool
  default     = true
  description = " Specify if you want your event selector to include management events for your trail."
}

variable "data_resource" {
  type        = bool
  default     = true
  description = " Specify if you want your event selector to include management events for your trail."
}

variable "event_selector_data_resource" {
  type        = bool
  default     = false
  description = "Specifies logging data events. Fields documented below."
}

variable "data_resource_type" {
  type        = string
  default     = "AWS::S3::Object"
  description = "The resource type in which you want to log data events. You can specify only the following value: `AWS::S3::Object` `AWS::Lambda::Function`."
}

variable "data_resource_values" {
  type        = list(string)
  default     = ["arn:aws:s3:::my_corporate_bucket"]
  description = "A list of ARN for the specified S3 buckets and object prefixes."
}

variable "kms_key_id" {
  type        = string
  default     = ""
  description = "Specifies the KMS key ARN to use to encrypt the logs delivered by CloudTrail."
}

variable "is_organization_trail" {
  type        = bool
  default     = false
  description = "The trail is an AWS Organizations trail."
}

variable "sns_topic_name" {
  type        = string
  default     = null
  description = "Specifies the name of the Amazon SNS topic defined for notification of log file delivery."
}