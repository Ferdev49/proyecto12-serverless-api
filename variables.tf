variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "proyecto12"
}

variable "api_name" {
  description = "API Gateway name"
  type        = string
  default     = "proyecto12-api"
}

variable "api_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "prod"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda memory in MB"
  type        = number
  default     = 256
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "enable_xray_tracing" {
  description = "Enable X-Ray tracing for Lambda"
  type        = bool
  default     = false
}

variable "api_key_description" {
  description = "API Key description"
  type        = string
  default     = "API Key for Proyecto 12 Serverless API"
}