output "base_api_url" {
  value       = aws_api_gateway_deployment.apig-deployment.invoke_url
  description = "Final HTTP endpoint for API, without the stage"
}

output "api_url_test_endpoint" {
  value       = "${aws_api_gateway_deployment.apig-deployment.invoke_url}${var.stage_name}/${var.api_path_part}"
  description = "Final full URL for the API"
}

output "api_id" {
  value       = aws_api_gateway_rest_api.apig.id
  description = "AWS API ID for the API created"
}

output "api_root_resource_id" {
  value       = aws_api_gateway_rest_api.apig.root_resource_id
  description = "The resource ID of the REST API's root"
}

output "lambda_arn" {
  value       = aws_lambda_function.lambda.arn
  description = "The ARN for Lambda function created"
}
