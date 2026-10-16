variable "aws_region" {
  type        = string
  description = "Target AWS deployment region"
  default     = "eu-west-3"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "staging"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "bucket_name" {
  type        = string
  description = "Base name for the secure S3 storage bucket"
  default     = "app-data-storage"
}

variable "queue_name" {
  type        = string
  description = "Name for the asynchronous event ingestion SQS queue"
  default     = "app-events-queue"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags applied to all provisions"
  default = {
    Application = "Enterprise-Core"
    ManagedBy   = "Terraform"
  }
}
