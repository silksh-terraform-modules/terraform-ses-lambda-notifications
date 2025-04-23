output "sns_topic_arn" {
  description = "ARN of SNS topic for SES notifications."
  value       = aws_sns_topic.ses_notifications.arn
}

output "s3_bucket_name" {
  description = "Name of S3 bucket for storing notifications."
  value       = aws_s3_bucket.ses_notifications.id
}

output "lambda_function_arn" {
  description = "ARN of Lambda function."
  value       = aws_lambda_function.ses_notifications.arn
}