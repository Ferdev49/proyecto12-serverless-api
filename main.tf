# ===== GET CURRENT ACCOUNT ID =====
data "aws_caller_identity" "current" {}

# ===== DYNAMODB TABLE =====
resource "aws_dynamodb_table" "users" {
  name           = "${var.project_name}-users"
  billing_mode   = var.dynamodb_billing_mode
  hash_key       = "id"
  
  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-users-table"
  }
}

# ===== IAM ROLE FOR LAMBDA =====
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-lambda-role"
  }
}

# ===== IAM POLICY FOR LAMBDA (DynamoDB + Logs) =====
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "${var.project_name}-lambda-policy"
  role   = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.users.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.project_name}-*"
      }
    ]
  })
}

# ===== LAMBDA: LIST USERS =====
resource "aws_lambda_function" "list_users" {
  filename      = "lambda_list_users.zip"
  function_name = "${var.project_name}-list-users"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_list_users.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.users.name
    }
  }

  depends_on = [aws_iam_role_policy.lambda_policy]

  tags = {
    Name = "${var.project_name}-list-users"
  }
}

# ===== LAMBDA: CREATE USER =====
resource "aws_lambda_function" "create_user" {
  filename      = "lambda_create_user.zip"
  function_name = "${var.project_name}-create-user"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_create_user.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.users.name
    }
  }

  depends_on = [aws_iam_role_policy.lambda_policy]

  tags = {
    Name = "${var.project_name}-create-user"
  }
}

# ===== LAMBDA: GET USER =====
resource "aws_lambda_function" "get_user" {
  filename      = "lambda_get_user.zip"
  function_name = "${var.project_name}-get-user"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_get_user.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.users.name
    }
  }

  depends_on = [aws_iam_role_policy.lambda_policy]

  tags = {
    Name = "${var.project_name}-get-user"
  }
}

# ===== LAMBDA: UPDATE USER =====
resource "aws_lambda_function" "update_user" {
  filename      = "lambda_update_user.zip"
  function_name = "${var.project_name}-update-user"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_update_user.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.users.name
    }
  }

  depends_on = [aws_iam_role_policy.lambda_policy]

  tags = {
    Name = "${var.project_name}-update-user"
  }
}

# ===== LAMBDA: DELETE USER =====
resource "aws_lambda_function" "delete_user" {
  filename      = "lambda_delete_user.zip"
  function_name = "${var.project_name}-delete-user"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_delete_user.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.users.name
    }
  }

  depends_on = [aws_iam_role_policy.lambda_policy]

  tags = {
    Name = "${var.project_name}-delete-user"
  }
}

# ===== API GATEWAY REST API =====
resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = "Serverless API for ${var.project_name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name = var.api_name
  }
}

# ===== API GATEWAY RESOURCES =====
resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_resource" "user_by_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.users.id
  path_part   = "{id}"
}

# ===== API GATEWAY METHODS =====

# GET /users
resource "aws_api_gateway_method" "get_users" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.users.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "get_users" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.users.id
  http_method      = aws_api_gateway_method.get_users.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.list_users.invoke_arn
}

# POST /users
resource "aws_api_gateway_method" "post_users" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.users.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "post_users" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.users.id
  http_method      = aws_api_gateway_method.post_users.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.create_user.invoke_arn
}

# GET /users/{id}
resource "aws_api_gateway_method" "get_user" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.user_by_id.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "get_user" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.user_by_id.id
  http_method      = aws_api_gateway_method.get_user.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.get_user.invoke_arn
}

# PUT /users/{id}
resource "aws_api_gateway_method" "put_user" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.user_by_id.id
  http_method      = "PUT"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "put_user" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.user_by_id.id
  http_method      = aws_api_gateway_method.put_user.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.update_user.invoke_arn
}

# DELETE /users/{id}
resource "aws_api_gateway_method" "delete_user" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.user_by_id.id
  http_method      = "DELETE"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "delete_user" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.user_by_id.id
  http_method      = aws_api_gateway_method.delete_user.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.delete_user.invoke_arn
}

# ===== API GATEWAY DEPLOYMENT =====
resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_integration.get_users,
    aws_api_gateway_integration.post_users,
    aws_api_gateway_integration.get_user,
    aws_api_gateway_integration.put_user,
    aws_api_gateway_integration.delete_user
  ]
}

resource "aws_api_gateway_stage" "api" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.api_stage_name

  tags = {
    Name = "${var.api_name}-${var.api_stage_name}"
  }
}

# ===== API KEY =====
resource "aws_api_gateway_api_key" "api_key" {
  name        = "${var.project_name}-api-key"
  description = var.api_key_description
  enabled     = true

  tags = {
    Name = "${var.project_name}-api-key"
  }
}

# ===== API USAGE PLAN =====
resource "aws_api_gateway_usage_plan" "usage_plan" {
  name       = "${var.project_name}-usage-plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.api.stage_name
  }

  tags = {
    Name = "${var.project_name}-usage-plan"
  }
}

# ===== USAGE PLAN API KEY ASSOCIATION =====
resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}

# ===== LAMBDA PERMISSIONS =====
resource "aws_lambda_permission" "allow_apigateway_list_users" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_users.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/*"
}

resource "aws_lambda_permission" "allow_apigateway_create_user" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/*"
}

resource "aws_lambda_permission" "allow_apigateway_get_user" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/*"
}

resource "aws_lambda_permission" "allow_apigateway_update_user" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/*"
}

resource "aws_lambda_permission" "allow_apigateway_delete_user" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/*"
}

# ===== CLOUDWATCH LOG GROUPS FOR LAMBDA =====
resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each = {
    list_users  = aws_lambda_function.list_users.function_name
    create_user = aws_lambda_function.create_user.function_name
    get_user    = aws_lambda_function.get_user.function_name
    update_user = aws_lambda_function.update_user.function_name
    delete_user = aws_lambda_function.delete_user.function_name
  }

  name              = "/aws/lambda/${each.value}"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-lambda-logs-${each.key}"
  }
}