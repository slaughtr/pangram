provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {}
  required_version = ">= 0.12.0"
}

# Lambda

data "archive_file" "lambda-zip" {
  type        = "zip"
  source_dir  = "src"
  output_path = "${var.name}.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name = var.name
  description   = "Lambda for ${var.name}"
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  role          = aws_iam_role.lambda_role.arn
  filename      = "${var.name}.zip"

  tags = var.tags
}


# API Permissions
resource "aws_lambda_permission" "allow_api_gateway" {
  function_name = var.name
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.apig.execution_arn}/*/*/*"

  depends_on = [
    aws_api_gateway_rest_api.apig,
    aws_api_gateway_resource.receive-lambda,
  ]
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.name}-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = var.tags

}

resource "aws_iam_role_policy" "logs" {
  name = "${aws_iam_role.lambda_role.name}-logs"
  role = aws_iam_role.lambda_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF

}

# APIG

resource "aws_api_gateway_rest_api" "apig" {
  name        = var.name
  description = var.api_description

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "*"
        }
    ]
}
EOF

  tags = var.tags

}

resource "aws_api_gateway_stage" "test" {
  stage_name    = var.stage_name
  rest_api_id   = aws_api_gateway_rest_api.apig.id
  deployment_id = aws_api_gateway_deployment.apig-deployment.id

  tags = var.tags
}

resource "aws_api_gateway_deployment" "apig-deployment" {
  depends_on = [
    aws_api_gateway_integration.ResourceOptionsIntegration-lambda,
    aws_api_gateway_integration.integration-lambda,
  ]

  rest_api_id = aws_api_gateway_rest_api.apig.id
  stage_name  = "" # leave blank
}

resource "aws_api_gateway_resource" "receive-lambda" {
  rest_api_id = aws_api_gateway_rest_api.apig.id
  parent_id   = aws_api_gateway_rest_api.apig.root_resource_id
  path_part   = var.api_path_part
}

resource "aws_api_gateway_method_response" "sc-200-lambda" {
  rest_api_id = aws_api_gateway_rest_api.apig.id
  resource_id = aws_api_gateway_resource.receive-lambda.id
  http_method = aws_api_gateway_method.method-lambda.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "sc-404-lambda" {
  rest_api_id = aws_api_gateway_rest_api.apig.id
  resource_id = aws_api_gateway_resource.receive-lambda.id
  http_method = aws_api_gateway_method.method-lambda.http_method
  status_code = "404"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "sc-503-lambda" {
  rest_api_id = aws_api_gateway_rest_api.apig.id
  resource_id = aws_api_gateway_resource.receive-lambda.id
  http_method = aws_api_gateway_method.method-lambda.http_method
  status_code = "503"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "method-lambda" {
  rest_api_id   = aws_api_gateway_rest_api.apig.id
  resource_id   = aws_api_gateway_resource.receive-lambda.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration-lambda" {
  rest_api_id = aws_api_gateway_rest_api.apig.id
  resource_id = aws_api_gateway_resource.receive-lambda.id
  http_method = aws_api_gateway_method.method-lambda.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn

  request_templates = {
    "application/json" = <<PARAMS
{ statusCode: 200 }
PARAMS

  }
}

resource "aws_api_gateway_method" "ResourceOptions-lambda" {
  rest_api_id   = aws_api_gateway_rest_api.apig.id
  resource_id   = aws_api_gateway_resource.receive-lambda.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "ResourceOptionsIntegration-lambda" {
  rest_api_id = aws_api_gateway_rest_api.apig.id
  resource_id = aws_api_gateway_resource.receive-lambda.id
  http_method = aws_api_gateway_method.ResourceOptions-lambda.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<PARAMS
{ "statusCode": 200 }
PARAMS

  }
}

resource "aws_api_gateway_integration_response" "ResourceOptionsIntegrationResponse-lambda" {
  depends_on  = [aws_api_gateway_integration.ResourceOptionsIntegration-lambda]
  rest_api_id = aws_api_gateway_rest_api.apig.id
  resource_id = aws_api_gateway_resource.receive-lambda.id
  http_method = aws_api_gateway_method.ResourceOptions-lambda.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS,GET,PUT,PATCH,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_method_response" "ResourceOptions200-lambda" {
  depends_on  = [aws_api_gateway_method.ResourceOptions-lambda]
  rest_api_id = aws_api_gateway_rest_api.apig.id
  resource_id = aws_api_gateway_resource.receive-lambda.id
  http_method = "OPTIONS"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

