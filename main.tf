# Define the provider and region
provider "aws" {
  profile = "default"
  region  = "ap-southeast-2"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/python/main.py"
  output_path = "${path.module}/python/main.py.zip"
}

resource "random_pet" "lambda_bucket_name" {
  prefix = "lambda"
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

# ----------------------------------------------------------------------------------------------------------------------
# FETCH DEFAULT VPC DATA AND PASS TO THE LAMBDA FUNCTIONS VPC CONFIG
# ----------------------------------------------------------------------------------------------------------------------

# resource "aws_default_vpc" "default" {
# }

# data "aws_subnet" "default" {
#   vpc_id = aws_default_vpc.default.id
# }

# resource "aws_default_security_group" "default" {
#   vpc_id = aws_default_vpc.default.id
# }


# Define the IAM policy for the Lambda function
resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda-api-retrieval-policy"
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
  handler       = "main.lambda_handler"
  runtime       = "python3.7"
  memory_size   = 128
  timeout       = 5

  # Use the IAM role we created earlier
  role = aws_iam_role.lambda_role.arn

  # Include the Lambda function code
  filename = "${path.module}/python/main.py.zip"
  # source_code_hash = filebase64sha256("${path.module}/python/main.py.zip")
  source_code_hash = data.archive_file.lambda.output_base64sha256

  # Set environment variables
  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.lambda_bucket.id,
      NOTHING = "nothing"
    }
  }
}