variable "sns_topic_name" {
  description = "Name of SNS topic for SES notifications"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of S3 bucket for storing notifications"
  type        = string
}

variable "lambda_role_name" {
  description = "Name of IAM role for Lambda function"
  type        = string
}

variable "lambda_policy_name" {
  description = "Name of IAM policy for Lambda function"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
}
