output "lambda_bucket_name" {
  description = "The Lambda Bucket name"
  value       = try(aws_s3_bucket.lambda_bucket.id, "")
}