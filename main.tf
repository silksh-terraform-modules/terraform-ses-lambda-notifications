resource "aws_sns_topic" "ses_notifications" {
  name = var.sns_topic_name
}

resource "aws_s3_bucket" "ses_notifications" {
  bucket = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "ses_notifications" {
  bucket = aws_s3_bucket.ses_notifications.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = var.lambda_policy_name
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = [
          "${aws_s3_bucket.ses_notifications.arn}",
          "${aws_s3_bucket.ses_notifications.arn}/*"
        ]
      }
    ]
  })
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.js"
  output_path = "${path.module}/lambda/index.zip"
}

resource "aws_lambda_function" "ses_notifications" {
  filename         = data.archive_file.lambda.output_path
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  # source_code_hash = filebase64sha256("${path.module}/lambda/index.zip")
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.ses_notifications.id
    }
  }
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.ses_notifications.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.ses_notifications.arn
}

resource "aws_lambda_permission" "sns_invocation" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ses_notifications.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.ses_notifications.arn
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.ses_notifications.function_name}"
  retention_in_days = 14
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
} 