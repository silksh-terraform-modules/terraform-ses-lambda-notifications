# Terraform Module: SES Lambda Notifications

This Terraform module creates a complete solution for handling Amazon SES (Simple Email Service) notifications using AWS Lambda and S3.

## Functionality

The module creates the following resources:

- SNS Topic for receiving SES notifications
- S3 Bucket for storing notifications
- Lambda Function for processing notifications
- All necessary IAM roles and permissions
- CloudWatch log group for the Lambda function

## Required Variables

| Name | Description | Type |
|------|-------------|------|
| sns_topic_name | Name of the SNS topic for SES notifications | string |
| s3_bucket_name | Name of the S3 bucket for storing notifications | string |
| lambda_role_name | Name of the IAM role for the Lambda function | string |
| lambda_policy_name | Name of the IAM policy for the Lambda function | string |
| lambda_function_name | Name of the Lambda function | string |

## Outputs

| Name | Description |
|------|-------------|
| sns_topic_arn | ARN of the SNS topic for SES notifications |
| s3_bucket_name | Name of the S3 bucket for storing notifications |
| lambda_function_arn | ARN of the Lambda function |

## Usage Example

```hcl
module "ses_notifications" {
  source = "git@github.com:silksh-terraform-modules/terraform-ses-lambda-notifications.git"

  sns_topic_name      = "ses-notifications-topic"
  s3_bucket_name      = "ses-notifications-bucket"
  lambda_role_name    = "ses-notifications-lambda-role"
  lambda_policy_name  = "ses-notifications-lambda-policy"
  lambda_function_name = "ses-notifications-processor"
}
```

## Architecture

1. SES sends notifications to the SNS topic
2. SNS triggers the Lambda function
3. Lambda processes the notification and stores it in the S3 bucket
4. Lambda logs are stored in CloudWatch

## Security

- S3 bucket is configured as private (public access blocked)
- Lambda has minimal permissions for S3 write operations
- All resources are created with appropriate access policies 