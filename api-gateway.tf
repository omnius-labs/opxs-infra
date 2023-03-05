// https://github.com/hanabu/lambda-web
// https://github.com/hanabu/lambda-web/issues/9#issuecomment-1099771970

resource "aws_apigatewayv2_api" "opxs_api" {
  name          = "opxs_api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "opxs_api" {
  api_id                 = aws_apigatewayv2_api.opxs_api.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.opxs_api.invoke_arn
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "opxs_api" {
  api_id    = aws_apigatewayv2_api.opxs_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.opxs_api.id}"
}

resource "aws_apigatewayv2_stage" "opxs_api" {
  api_id      = aws_apigatewayv2_api.opxs_api.id
  name        = "$default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.opxs_api_http_api.arn
    format = jsonencode({
      requestId : "$context.requestId",
      ip : "$context.identity.sourceIp",
      requestTime : "$context.requestTime",
      httpMethod : "$context.httpMethod",
      routeKey : "$context.routeKey",
      status : "$context.status",
      protocol : "$context.protocol",
      responseLength : "$context.responseLength",
      errorMessage : "$context.error.message",
      errorResponseType : "$context.error.responseType"
      authorizerError : "$context.authorizer.error",
      integrationErrorMessage : "$context.integrationErrorMessage"
    })
  }
}

resource "aws_apigatewayv2_deployment" "opxs_api" {
  api_id      = aws_apigatewayv2_api.opxs_api.id
  description = "opxs_api deployment"
  triggers = {
    redeployment = sha1(filebase64("${path.module}/api-gateway.tf"))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "opxs_api_http_api" {
  name = "/aws/apigateway/opxs-api"
}
