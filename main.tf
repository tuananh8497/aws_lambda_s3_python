# Define the provider and region
provider "aws" {
  region = "ap-southeast-2"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "../${path.module}/python/main.py"
  output_path = "../${path.module}/python/main.py.zip"
}

# Create an S3 bucket
resource "aws_s3_bucket_acl" "api_staging_bucket" {
  bucket = "api-staging-bucket-20230505"
  acl    = "private"

  tags = {
    Name = "API data bucket"
  }
}

# Define the IAM policy for the Lambda function
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-policy"
  policy      = <<EOF
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
      "Resource": "${aws_s3_bucket.api_staging_bucket.arn}/*"
    }
  ]
}
EOF
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

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

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

# Create the Lambda function
resource "aws_lambda_function" "api_retrieval_function" {
  function_name = "api-retrieval-function"
  handler       = "lambda_function.handler"
  runtime       = "python3.10"
  memory_size   = 128
  timeout       = 5

  # Use the IAM role we created earlier
  role = aws_iam_role.lambda_role.arn

  # Include the Lambda function code
  filename      = "${path.module}/python/main.py.zip"

  # Set environment variables
  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.api_staging_bucket.id
    }
  }
}
