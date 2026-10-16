output "instance_id" {
  description = "Identifier of the provisioned compute instance"
  value       = aws_instance.app_node.id
}

output "instance_arn" {
  description = "ARN of the provisioned compute instance"
  value       = aws_instance.app_node.arn
}

output "volume_id" {
  description = "Identifier of the persistent EBS storage volume"
  value       = aws_ebs_volume.persistent_storage.id
}

output "volume_arn" {
  description = "ARN of the persistent EBS storage volume"
  value       = aws_ebs_volume.persistent_storage.arn
}
