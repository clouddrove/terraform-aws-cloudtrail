## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| attributes | Additional attributes (e.g. `1`). | `list(string)` | `[]` | no |
| cloud\_watch\_logs\_group\_arn | Specifies a log group name using an Amazon Resource Name (ARN), that represents the log group to which CloudTrail logs will be delivered. | `string` | `""` | no |
| cloud\_watch\_logs\_role\_arn | Specifies the role for the CloudWatch Logs endpoint to assume to write to a user’s log group. | `string` | `""` | no |
| cloudwatch\_log\_group\_name | The name of the CloudWatch Log Group that receives CloudTrail events. | `string` | `"cloudtrail-events"` | no |
| data\_resource\_type | The resource type in which you want to log data events. You can specify only the following value: `AWS::S3::Object` `AWS::Lambda::Function`. | `string` | `"AWS::S3::Object"` | no |
| data\_resource\_values | Specifies an event selector for enabling data event logging, It needs to be a list of map values. See: https://www.terraform.io/docs/providers/aws/r/cloudtrail.html for details on this map variable. | `list(string)` | `[]` | no |
| enable\_cloudwatch | If true, deploy the resources for cloudwatch in the module. | `bool` | `true` | no |
| enable\_log\_file\_validation | Specifies whether log file integrity validation is enabled. Creates signed digest for validated contents of logs. | `bool` | `true` | no |
| enable\_logging | Enable logging for the trail. | `bool` | `true` | no |
| enabled\_cloudtrail | If true, deploy the resources for the module. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| event\_selector | Specifies an event selector for enabling data event logging. Fields documented below. Please note the CloudTrail limits when configuring these. | `bool` | `true` | no |
| event\_selector\_data\_resource | Specifies logging data events. Fields documented below. | `bool` | `false` | no |
| iam\_role\_name | Name for the CloudTrail IAM role | `string` | `"cloudtrail-cloudwatch-logs-role"` | no |
| include\_global\_service\_events | Specifies whether the trail is publishing events from global services such as IAM to the log files. | `bool` | `true` | no |
| include\_management\_events | Specify if you want your event selector to include management events for your trail. | `bool` | `true` | no |
| insight\_selector | Specifies an insight selector for type of insights to log on a trail | <pre>list(object({<br>    insight_type = string<br>  }))</pre> | `[]` | no |
| is\_multi\_region\_trail | Specifies whether the trail is created in the current region or in all regions | `bool` | `false` | no |
| is\_organization\_trail | The trail is an AWS Organizations trail. | `bool` | `false` | no |
| key\_deletion\_window\_in\_days | Duration in days after which the key is deleted after destruction of the resource, must be 7-30 days.  Default 30 days. | `string` | `30` | no |
| kms\_enabled | If true, deploy the resources for kms in the module. Note: Supports in only single cloudtrail management. | `bool` | `false` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| log\_retention\_days | Number of days to keep AWS logs around in specific log group. | `string` | `90` | no |
| managedby | ManagedBy, eg 'CloudDrove'. | `string` | `"hello@clouddrove.com"` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | n/a | yes |
| read\_write\_type | Specify if you want your trail to log read-only events, write-only events, or all. By default, the value is All. | `string` | `"All"` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/clouddrove/terraform-aws-cloudtrail"` | no |
| s3\_bucket\_name | S3 bucket name for CloudTrail log. | `string` | `""` | no |
| s3\_key\_prefix | (Optional) S3 key prefix that follows the name of the bucket you have designated for log file delivery. | `string` | `""` | no |
| sns\_topic\_name | Specifies the name of the Amazon SNS topic defined for notification of log file delivery. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The Amazon Resource Name of the trail. |
| home\_region | The region in which the trail was created. |
| id | The name of the trail. |
| tags | A mapping of tags to assign to the resource. |
