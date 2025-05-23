locals {
  opxs_api_lambda_name                       = "opxs-api-lambda"
  opxs_batch_email_send_lambda_name          = "opxs-batch-email-send-lambda"
  opxs_batch_email_send_feedback_lambda_name = "opxs-batch-email-send-feedback-lambda"
  opxs_batch_file_convert_lambda_name        = "opxs-batch-file-convert-lambda"
}

resource "aws_lambda_function" "opxs_api" {
  function_name = local.opxs_api_lambda_name
  role          = aws_iam_role.opxs_api_lambda.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.opxs_api.repository_url}:latest"
  publish       = true

  memory_size = 128
  timeout     = 30

  environment {
    variables = {
      RUN_MODE       = var.run_mode
      RUST_BACKTRACE = "full"
    }
  }
  lifecycle {
    ignore_changes = [image_uri]
  }
  depends_on = [aws_cloudwatch_log_group.opxs_api_lambda]
}

resource "aws_lambda_permission" "opxs_api" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.opxs_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.opxs_api.execution_arn}/*/*"
}

resource "aws_iam_role" "opxs_api_lambda" {
  name               = "opxs-api-lambda-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "opxs_api_lambda" {
  name   = "opxs-api-lambda-policy"
  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"sqs:SendMessage"
			],
			"Resource": "*"
		},
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::opxs.v1.${var.run_mode}.file-convert/*"
            ]
        },
		{
			"Action": [
				"secretsmanager:GetSecretValue"
			],
			"Effect": "Allow",
            "Resource": "${aws_secretsmanager_secret.opxs.id}"
		}
	]
}
EOF
}

resource "aws_iam_role_policy_attachment" "opxs_api_lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.opxs_api_lambda.name
}

resource "aws_iam_role_policy_attachment" "opxs_api_lambda_additional" {
  role       = aws_iam_role.opxs_api_lambda.name
  policy_arn = aws_iam_policy.opxs_api_lambda.arn
}

resource "aws_cloudwatch_log_group" "opxs_api_lambda" {
  name              = "/aws/lambda/${local.opxs_api_lambda_name}"
  retention_in_days = 3
}


resource "aws_lambda_function" "opxs_batch_email_send" {
  function_name = local.opxs_batch_email_send_lambda_name
  role          = aws_iam_role.opxs_batch_email_send_lambda.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.opxs_batch_email_send.repository_url}:latest"
  publish       = true

  memory_size = 128
  timeout     = 60

  environment {
    variables = {
      RUN_MODE       = var.run_mode
      RUST_BACKTRACE = "full"
    }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [image_uri]
  }
  depends_on = [aws_cloudwatch_log_group.opxs_batch_email_send_lambda]
}

resource "aws_iam_role" "opxs_batch_email_send_lambda" {
  name               = "opxs-batch-email-send-lambda-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "opxs_batch_email_send_lambda" {
  name   = "opxs-batch-email-send-lambda-policy"
  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"sqs:DeleteMessage",
				"sqs:ReceiveMessage",
				"sqs:GetQueueAttributes"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ses:SendEmail"
			],
			"Resource": "*"
		},
		{
			"Action": [
				"secretsmanager:GetSecretValue"
			],
			"Effect": "Allow",
            "Resource": "${aws_secretsmanager_secret.opxs.id}"
		}
	]
}
EOF
}

resource "aws_iam_role_policy_attachment" "opxs_batch_email_send_lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.opxs_batch_email_send_lambda.name
}

resource "aws_iam_role_policy_attachment" "opxs_batch_email_send_lambda_additional" {
  role       = aws_iam_role.opxs_batch_email_send_lambda.name
  policy_arn = aws_iam_policy.opxs_batch_email_send_lambda.arn
}

resource "aws_cloudwatch_log_group" "opxs_batch_email_send_lambda" {
  name              = "/aws/lambda/${local.opxs_batch_email_send_lambda_name}"
  retention_in_days = 3
}

resource "aws_lambda_function" "opxs_batch_email_send_feedback" {
  function_name = local.opxs_batch_email_send_feedback_lambda_name
  role          = aws_iam_role.opxs_batch_email_send_feedback_lambda.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.opxs_batch_email_send_feedback.repository_url}:latest"
  publish       = true

  memory_size = 128
  timeout     = 60

  environment {
    variables = {
      RUN_MODE       = var.run_mode
      RUST_BACKTRACE = "full"
    }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [image_uri]
  }
  depends_on = [aws_cloudwatch_log_group.opxs_batch_email_send_feedback_lambda_log_group]
}

resource "aws_iam_role" "opxs_batch_email_send_feedback_lambda" {
  name = "opxs-batch-email-send-feedback-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "opxs_batch_email_send_feedback_lambda_policy" {
  name   = "opxs-batch-email-send-feedback-lambda-policy"
  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
                "sns:Subscribe"
			],
			"Resource": "*"
		},
		{
			"Action": [
				"secretsmanager:GetSecretValue"
			],
			"Effect": "Allow",
            "Resource": "${aws_secretsmanager_secret.opxs.id}"
		}
	]
}
EOF
}

resource "aws_iam_role_policy_attachment" "opxs_batch_email_send_feedback_lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.opxs_batch_email_send_feedback_lambda.name
}

resource "aws_iam_role_policy_attachment" "opxs_batch_email_send_feedback_lambda_additional" {
  role       = aws_iam_role.opxs_batch_email_send_feedback_lambda.name
  policy_arn = aws_iam_policy.opxs_batch_email_send_feedback_lambda_policy.arn
}

resource "aws_cloudwatch_log_group" "opxs_batch_email_send_feedback_lambda_log_group" {
  name              = "/aws/lambda/${local.opxs_batch_email_send_feedback_lambda_name}"
  retention_in_days = 3
}

resource "aws_lambda_function" "opxs_batch_file_convert" {
  function_name = local.opxs_batch_file_convert_lambda_name
  role          = aws_iam_role.opxs_batch_file_convert_lambda.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.opxs_batch_file_convert.repository_url}:latest"
  memory_size   = 1024
  timeout       = 180
  publish       = true

  environment {
    variables = {
      RUN_MODE       = var.run_mode
      RUST_BACKTRACE = "full"
    }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [image_uri]
  }
  depends_on = [aws_cloudwatch_log_group.opxs_batch_file_convert_lambda]
}

resource "aws_iam_role" "opxs_batch_file_convert_lambda" {
  name = "opxs-batch-file-convert-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "opxs_batch_file_convert_lambda" {
  name   = "opxs-batch-file-convert-lambda-policy"
  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sqs:DeleteMessage",
                "sqs:ReceiveMessage",
                "sqs:GetQueueAttributes"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::opxs.v1.${var.run_mode}.file-convert/*"
            ]
        },
		{
			"Action": [
				"secretsmanager:GetSecretValue"
			],
			"Effect": "Allow",
            "Resource": "${aws_secretsmanager_secret.opxs.id}"
		}
	]
}
EOF
}

resource "aws_iam_role_policy_attachment" "opxs_batch_file_convert_lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.opxs_batch_file_convert_lambda.name
}

resource "aws_iam_role_policy_attachment" "opxs_batch_file_convert_lambda_additional" {
  role       = aws_iam_role.opxs_batch_file_convert_lambda.name
  policy_arn = aws_iam_policy.opxs_batch_file_convert_lambda.arn
}

resource "aws_cloudwatch_log_group" "opxs_batch_file_convert_lambda" {
  name              = "/aws/lambda/${local.opxs_batch_file_convert_lambda_name}"
  retention_in_days = 3
}
