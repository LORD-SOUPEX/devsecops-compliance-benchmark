terraform {
  source = "../terraform"
}

inputs = {
  aws_region  = "eu-west-3"
  environment = "staging"
  bucket_name = "enterprise-asset-store"
  queue_name  = "order-processing-events"
  tags = {
    Application = "Enterprise-Core"
    Environment = "staging"
    ManagedBy   = "Terragrunt"
    Owner       = "Platform-Engineering"
  }
}
