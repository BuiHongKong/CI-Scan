output "app_data_bucket_name" {
  description = "Name of the application data S3 bucket"
  value       = aws_s3_bucket.app_data.id
}

output "app_data_bucket_arn" {
  description = "ARN of the application data S3 bucket"
  value       = aws_s3_bucket.app_data.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for S3 encryption"
  value       = aws_kms_key.app_data.arn
}

output "vpc_id" {
  description = "ID of the main VPC"
  value       = aws_vpc.main.id
}

output "security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app.id
}
