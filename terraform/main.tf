resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  description   = var.function_description
  role          = aws_iam_role.role.arn

  reserved_concurrent_executions = -1

  environment {
    variables = {
      WEBHOOK_SECRET = var.webhook_secret
    }
  }

  s3_bucket = var.bucket_package
  s3_key    = "lambda_default_package.zip"
  handler   = var.handler
  runtime   = var.runtime

  memory_size = 1024
  timeout     = 180
}

