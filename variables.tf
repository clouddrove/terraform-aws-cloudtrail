variable "name" {
  description = "Name of the resource."
  type        = string
}

variable "repository" {
  description = "Repository name where this module is used."
  type        = string
}

variable "environment" {
  description = "Environment (e.g. dev, prod, staging)."
  type        = string
}

variable "managedby" {
  description = "Team responsible for this resource."
  type        = string
}

variable "attributes" {
  description = "List of attributes to add to the name."
  type        = list(string)
  default     = []
}

variable "label_order" {
  description = "Label order."
  type        = list(string)
  default     = ["name", "environment"]
}

# CloudTrail-specific variables
variable "enabled_cloudtrail" {
  description = "Enable CloudTrail."
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable logging for the CloudTrail."
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Enable log file validation for the trail."
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Whether the trail is multi-region."
  type        = bool
  default     = true
}

variable "include_global_service_events" {
  description = "Include global service events in the trail."
  type        = bool
  default     = true
}

variable "is_organization_trail" {
  description = "Whether the trail is for an organization."
  type        = bool
  default     = false
}

variable "s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs."
  type        = string
}

variable "s3_key_prefix" {
  description = "S3 key prefix for CloudTrail logs."
  type        = string
  default     = ""
}

variable "create_s3_bucket" {
  description = "Whether to create the S3 bucket or assume it exists."
  type        = bool
  default     = true
}

variable "cloud_watch_logs_role_arn" {
  description = "The ARN of the IAM role that CloudTrail assumes to write to CloudWatch Logs."
  type        = string
  default     = ""
}

variable "cloud_watch_logs_group_arn" {
  description = "The ARN of the CloudWatch Logs log group."
  type        = string
  default     = ""
}

variable "sns_topic_name" {
  description = "Name of the SNS topic for CloudTrail notifications."
  type        = string
  default     = ""
}

# KMS
variable "kms_enabled" {
  description = "Enable KMS encryption for CloudTrail logs."
  type        = bool
  default     = true
}

variable "key_deletion_window_in_days" {
  description = "Number of days before deleting the KMS key."
  type        = number
  default     = 30
}

# CloudWatch
variable "enable_cloudwatch" {
  description = "Enable CloudWatch logging for CloudTrail."
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_name" {
  description = "CloudWatch log group name."
  type        = string
  default     = "/aws/cloudtrail/logs"
}

variable "log_retention_days" {
  description = "Retention in days for CloudWatch logs."
  type        = number
  default     = 90
}

# IAM Names
variable "iam_role_name" {
  description = "IAM role name for CloudTrail CloudWatch integration."
  type        = string
  default     = "cloudtrail-cloudwatch-logs-role"
}

variable "iam_policy_name" {
  description = "IAM policy name for CloudWatch permissions."
  type        = string
  default     = "cloudtrail-cloudwatch-logs-policy"
}

# Insight selectors
variable "insight_selector" {
  description = "List of insight selectors to enable on the trail."
  type = list(object({
    insight_type = string
  }))
  default = []
}

# Advanced event selectors (optional)
variable "event_selector" {
  description = "Enable event selector for data events."
  type        = bool
  default     = false
}

variable "event_selector_data_resource" {
  description = "Enable data resource configuration for event selector."
  type        = bool
  default     = false
}

variable "read_write_type" {
  description = "Specifies whether to log read-only, write-only, or all events."
  type        = string
  default     = "All"
}

variable "include_management_events" {
  description = "Include management events for event selector."
  type        = bool
  default     = true
}

variable "data_resource_type" {
  description = "Type of data resource (e.g., AWS::S3::Object)."
  type        = string
  default     = "AWS::S3::Object"
}

variable "data_resource_values" {
  description = "List of data resource ARNs to include in the event selector."
  type        = list(string)
  default     = []
}
