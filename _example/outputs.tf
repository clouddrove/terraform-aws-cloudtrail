output "cloudtrail_id" {
  value       = module.cloudtrail.*.id
  description = "The name of the trail"
}

output "cloudtrail_arn" {
  value       = module.cloudtrail.*.arn
  description = "The Amazon Resource Name of the trail"
}

output "cloudtrail_home_region" {
  value       = module.cloudtrail.*.home_region
  description = "The region in which the trail was created"
}

output "tags" {
  value       = module.cloudtrail.tags
  description = "A mapping of tags to assign to the Cloudtrail."
}
