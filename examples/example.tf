module "cloudtrail" {
  source                        = "../"
  name                          = "cloudtrail"
  application                   = "clouddrove"
  environment                   = "security"
  enable_logging                = "true"
  enable_log_file_validation    = "true"
  include_global_service_events = "true"
  is_multi_region_trail         = "false"
}
