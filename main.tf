# Define the provider and region
provider "aws" {
  profile = var.default_profile
  region  = var.default_region
}

data "archive_file" "lambda" {
  type        = var.archive_file_format
  source_file = var.archive_python_source_file
  output_path = var.archive_python_output_path
}

resource "random_pet" "lambda_bucket_name" {
  prefix = var.lambda_prefix_name
  length = 2
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = random_pet.lambda_bucket_name.id
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

# Define the IAM policy for the Lambda function
resource "aws_iam_policy" "lambda_policy" {
  name = var.lambda_policy_name
  # policy = var.iam_role_lambda_policy
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "logs:*",
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "${aws_s3_bucket.lambda_bucket.arn}/*"
    }
  ]
}
EOF
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = var.lambda_policy_name

  # assume_role_policy = var.iam_role_lambda_assume_role_policy
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_event_rule" "trigger_api_retrieval" {
  name                = var.aws_cloudwatch_event_rule_name
  description         = var.aws_cloudwatch_event_rule_description
  schedule_expression = var.aws_cloudwatch_event_rule_schedule
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = var.aws_lambda_permission_statement_id
  action        = var.aws_lambda_permission_action
  function_name = aws_lambda_function.api_retrieval_function.function_name
  principal     = var.aws_lambda_permission_principal
  source_arn    = aws_cloudwatch_event_rule.trigger_api_retrieval.arn
}

resource "aws_cloudwatch_event_target" "cloudwatch_event_rule" {
  rule = aws_cloudwatch_event_rule.trigger_api_retrieval.name
  arn  = aws_lambda_function.api_retrieval_function.arn
}

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

# Create the Lambda function
resource "aws_lambda_function" "api_retrieval_function" {
  function_name = var.aws_lambda_function_name
  handler       = var.aws_lambda_function_handler
  runtime       = var.aws_lambda_function_runtime
  memory_size   = var.aws_lambda_function_memory_size
  timeout       = var.aws_lambda_function_timeout

  # Use the IAM role we created earlier
  role = aws_iam_role.lambda_role.arn

  # Include the Lambda function code
  filename         = var.archive_python_output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  # Set environment variables
  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.lambda_bucket.id
    }
  }
}