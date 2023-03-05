resource "aws_lambda_function" "opxs_api" {
  depends_on = [
    aws_cloudwatch_log_group.opxs_api_lambda,
  ]

  function_name = "opxs-api"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.opxs_api_lambda.repository_url}:latest"
  role          = aws_iam_role.opxs_api_lambda.arn
  publish       = true

  memory_size = 128
  timeout     = 30

  environment {
    variables = {
      RUN_MODE       = var.run_mode
      RUST_BACKTRACE = "full"
    }
  }
}

resource "aws_lambda_permission" "opxs_api" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.opxs_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.opxs_api.execution_arn}/*/*"
}

resource "aws_iam_role" "opxs_api_lambda" {
  name               = "opxs-api-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.opxs_api_lambda_role.json
}

data "aws_iam_policy_document" "opxs_api_lambda_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "opxs_api_lambda" {
  role       = aws_iam_role.opxs_api_lambda.name
  policy_arn = aws_iam_policy.opxs_api_lambda.arn
}

resource "aws_iam_policy" "opxs_api_lambda" {
  name   = "opxs-api-lambda-policy"
  policy = data.aws_iam_policy_document.opxs_api_lambda_policy.json
}

data "aws_iam_policy_document" "opxs_api_lambda_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      aws_secretsmanager_secret.opxs_api.id,
    ]
  }
}

resource "aws_cloudwatch_log_group" "opxs_api_lambda" {
  name              = "/aws/lambda/opxs-api"
  retention_in_days = 3
}
