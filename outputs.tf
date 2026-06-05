output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_api_gateway_stage.api.invoke_url
}

output "api_id" {
  description = "API Gateway API ID"
  value       = aws_api_gateway_rest_api.api.id
}

output "api_key_value" {
  description = "API Key value"
  value       = aws_api_gateway_api_key.api_key.value
  sensitive   = true
}

output "api_key_id" {
  description = "API Key ID"
  value       = aws_api_gateway_api_key.api_key.id
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.users.name
}

output "lambda_role_arn" {
  description = "Lambda execution role ARN"
  value       = aws_iam_role.lambda_role.arn
}

output "list_users_function_arn" {
  description = "List Users Lambda function ARN"
  value       = aws_lambda_function.list_users.arn
}

output "create_user_function_arn" {
  description = "Create User Lambda function ARN"
  value       = aws_lambda_function.create_user.arn
}

output "get_user_function_arn" {
  description = "Get User Lambda function ARN"
  value       = aws_lambda_function.get_user.arn
}

output "update_user_function_arn" {
  description = "Update User Lambda function ARN"
  value       = aws_lambda_function.update_user.arn
}

output "delete_user_function_arn" {
  description = "Delete User Lambda function ARN"
  value       = aws_lambda_function.delete_user.arn
}

output "api_documentation" {
  description = "API endpoints and usage"
  value = {
    endpoint = aws_api_gateway_stage.api.invoke_url
    api_key  = "See sensitive output: terraform output api_key_value"
    endpoints = {
      list_users  = "GET ${aws_api_gateway_stage.api.invoke_url}/users"
      create_user = "POST ${aws_api_gateway_stage.api.invoke_url}/users"
      get_user    = "GET ${aws_api_gateway_stage.api.invoke_url}/users/{id}"
      update_user = "PUT ${aws_api_gateway_stage.api.invoke_url}/users/{id}"
      delete_user = "DELETE ${aws_api_gateway_stage.api.invoke_url}/users/{id}"
    }
    headers = {
      "x-api-key" = "tu-api-key"
    }
  }
}