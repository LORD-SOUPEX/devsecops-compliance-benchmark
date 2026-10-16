output "bucket_id" {
  description = "The identifier of the deployed S3 bucket"
  value       = aws_s3_bucket.app_storage.id
}

output "bucket_arn" {
  description = "The ARN of the deployed S3 bucket"
  value       = aws_s3_bucket.app_storage.arn
}

output "kms_key_arn" {
  description = "The ARN of the customer-managed KMS key used for encryption"
  value       = aws_kms_key.storage_key.arn
}

output "sqs_queue_id" {
  description = "The URL of the primary SQS queue"
  value       = aws_sqs_queue.app_queue.id
}

output "sqs_queue_arn" {
  description = "The ARN of the primary SQS queue"
  value       = aws_sqs_queue.app_queue.arn
}
