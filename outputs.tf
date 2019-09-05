#Module      : CloudTrail
#Description : Terraform module to provision an AWS CloudTrail with encrypted S3 bucket.
#              This bucket is used to store CloudTrail logs.
output "id" {
  value = concat(
    aws_cloudtrail.default.*.id
  )[0]
  description = "The name of the trail."
}

output "home_region" {
  value = concat(
    aws_cloudtrail.default.*.home_region
  )[0]
  description = "The region in which the trail was created."
}

output "arn" {
  value = concat(
    aws_cloudtrail.default.*.arn
  )[0]
  description = "The Amazon Resource Name of the trail."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}