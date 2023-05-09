variable "default_profile" {
  type        = string
  description = "Profile setting"
  default     = "default"
}

variable "default_region" {
  type        = string
  description = "Default Region setting"
  default     = "ap-southeast-2"
}

variable "lambda_prefix_name" {
  type        = string
  description = "Lambda prefix name"
}

variable "lambda_policy_name" {
  type        = string
  description = "Lambda policy Name"
}

variable "lambda_policy_role" {
  type        = string
  description = "Lambda policy role"
}

variable "aws_cloudwatch_event_rule_name" {
  type        = string
  description = "AWS CloudWatch event rule name"
}

variable "aws_cloudwatch_event_rule_description" {
  type        = string
  description = "AWS CloudWatch event rule description"
}

variable "aws_cloudwatch_event_rule_schedule" {
  type        = string
  description = "AWS CloudWatch event rule schedule expression"
}

variable "archive_python_source_file" {
  type        = string
  description = "Archive python source file"
}

variable "archive_python_output_path" {
  type        = string
  description = "Archive Python output path"
}

variable "archive_file_format" {
  type        = string
  description = "Archive file format"
}

variable "aws_lambda_permission_statement_id" {
  type        = string
  description = "Statement ID for AWS Lambda Permission"
}

variable "aws_lambda_permission_action" {
  type        = string
  description = "Action for AWS Lambda Permission"
}

variable "aws_lambda_permission_principal" {
  type        = string
  description = "Principle for AWS Lambda Permission"
}

variable "aws_lambda_function_name" {
  type        = string
  description = "Lambda Function name"
}

variable "aws_lambda_function_handler" {
  type        = string
  description = "Lambda Function handler"
}

variable "aws_lambda_function_runtime" {
  type        = string
  description = "Lambda Function runtime"
}

variable "aws_lambda_function_memory_size" {
  type        = number
  description = "Lambda Function memory size"
  default     = 128
}

variable "aws_lambda_function_timeout" {
  type        = number
  description = "Lambda Function timeout"
  default     = 5
}