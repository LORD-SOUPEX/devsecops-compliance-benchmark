terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      var.tags,
      {
        Environment = var.environment
      }
    )
  }
}

# KMS Key for dedicated customer-managed encryption
resource "aws_kms_key" "storage_key" {
  description             = "KMS Key for ${var.environment} S3 and SQS data-at-rest encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_kms_alias" "storage_key_alias" {
  name          = "alias/${var.environment}-storage-key"
  target_key_id = aws_kms_key.storage_key.key_id
}

# S3 Bucket with SSE-KMS, Versioning, and Lifecycle
resource "aws_s3_bucket" "app_storage" {
  bucket        = "${var.bucket_name}-${var.environment}"
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "app_storage_versioning" {
  bucket = aws_s3_bucket.app_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_storage_encryption" {
  bucket = aws_s3_bucket.app_storage.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.storage_key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "app_storage_access_block" {
  bucket = aws_s3_bucket.app_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "app_storage_lifecycle" {
  bucket     = aws_s3_bucket.app_storage.id
  depends_on = [aws_s3_bucket_versioning.app_storage_versioning]

  rule {
    id     = "archive-and-expire-old-data"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }

    noncurrent_version_expiration {
      noncurrent_days = 60
    }
  }
}

# Associated SQS Queue with KMS Encryption and DLQ
resource "aws_sqs_queue" "app_deadletter_queue" {
  name                      = "${var.queue_name}-${var.environment}-dlq"
  kms_master_key_id         = aws_kms_key.storage_key.id
  message_retention_seconds = 1209600 # 14 days
}

resource "aws_sqs_queue" "app_queue" {
  name                      = "${var.queue_name}-${var.environment}"
  delay_seconds             = 0
  max_message_size          = 262144 # 256 KiB
  message_retention_seconds = 345600 # 4 days
  receive_wait_time_seconds = 10     # Long polling
  kms_master_key_id         = aws_kms_key.storage_key.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.app_deadletter_queue.arn
    maxReceiveCount     = 5
  })
}
