locals {
  opxs_api_lambda_name                       = "opxs-api-lambda"
  opxs_batch_email_send_lambda_name          = "opxs-batch-email-send-lambda"
  opxs_batch_email_send_feedback_lambda_name = "opxs-batch-email-send-feedback-lambda"
  opxs_batch_image_convert_lambda_name       = "opxs-batch-image-convert-lambda"
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
            "Sid": "AWSLambdaVPCAccessExecutionPermissions",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
		{
			"Action": [
				"secretsmanager:GetSecretValue"
			],
			"Effect": "Allow",
            "Resource": "${aws_secretsmanager_secret.opxs.id}"
		},
        {
            "Action": [
                "execute-api:Invoke"
            ],
            "Effect": "Allow",
            "Principal": {
                "Service": "com.amazonaws.global.cloudfront.origin-facing"
            },
            "Resource": "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_apigatewayv2_api.opxs_api.id}/*/*/*"
        }
	]
}
EOF
}

resource "aws_iam_role_policy_attachment" "opxs_api_lambda" {
  role       = aws_iam_role.opxs_api_lambda.name
  policy_arn = aws_iam_policy.opxs_api_lambda.arn
}

resource "aws_cloudwatch_log_group" "opxs_api_lambda" {
  name              = "/aws/lambda/${local.opxs_api_lambda_name}"
  retention_in_days = 3
}


resource "aws_lambda_function" "opxs_batch_email_send_lambda" {
  function_name = local.opxs_batch_email_send_lambda_name
  role          = aws_iam_role.opxs_batch_email_send_lambda_role.arn
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
  depends_on = [aws_cloudwatch_log_group.opxs_batch_email_send_lambda_log_group]
}

resource "aws_iam_role" "opxs_batch_email_send_lambda_role" {
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

resource "aws_iam_policy" "opxs_batch_email_send_lambda_policy" {
  name   = "opxs-batch-email-send-lambda-policy"
  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
        {
            "Sid": "AWSLambdaVPCAccessExecutionPermissions",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSubnets",
                "ec2:DeleteNetworkInterface",
                "ec2:AssignPrivateIpAddresses",
                "ec2:UnassignPrivateIpAddresses"
            ],
            "Resource": "*"
        },
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

resource "aws_iam_role_policy_attachment" "opxs_batch_email_send_lambda_policy_attachment" {
  role       = aws_iam_role.opxs_batch_email_send_lambda_role.name
  policy_arn = aws_iam_policy.opxs_batch_email_send_lambda_policy.arn
}

resource "aws_cloudwatch_log_group" "opxs_batch_email_send_lambda_log_group" {
  name              = "/aws/lambda/${local.opxs_batch_email_send_lambda_name}"
  retention_in_days = 3
}

resource "aws_lambda_function" "opxs_batch_email_send_feedback_lambda" {
  function_name = local.opxs_batch_email_send_feedback_lambda_name
  role          = aws_iam_role.opxs_batch_email_send_feedback_lambda_role.arn
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

resource "aws_iam_role" "opxs_batch_email_send_feedback_lambda_role" {
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
            "Sid": "AWSLambdaVPCAccessExecutionPermissions",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSubnets",
                "ec2:DeleteNetworkInterface",
                "ec2:AssignPrivateIpAddresses",
                "ec2:UnassignPrivateIpAddresses"
            ],
            "Resource": "*"
        },
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

resource "aws_iam_role_policy_attachment" "opxs_batch_email_send_feedback_lambda_policy_attachment" {
  role       = aws_iam_role.opxs_batch_email_send_feedback_lambda_role.name
  policy_arn = aws_iam_policy.opxs_batch_email_send_feedback_lambda_policy.arn
}

resource "aws_cloudwatch_log_group" "opxs_batch_email_send_feedback_lambda_log_group" {
  name              = "/aws/lambda/${local.opxs_batch_email_send_feedback_lambda_name}"
  retention_in_days = 3
}

resource "aws_lambda_function" "opxs_batch_image_convert_lambda" {
  function_name = local.opxs_batch_image_convert_lambda_name
  role          = aws_iam_role.opxs_batch_image_convert_lambda_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.opxs_batch_image_convert.repository_url}:latest"
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
  depends_on = [aws_cloudwatch_log_group.opxs_batch_image_convert_lambda_log_group]
}

resource "aws_iam_role" "opxs_batch_image_convert_lambda_role" {
  name = "opxs-batch-image-convert-lambda-role"

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

resource "aws_iam_policy" "opxs_batch_image_convert_lambda_policy" {
  name   = "opxs-batch-image-convert-lambda-policy"
  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
        {
            "Sid": "AWSLambdaVPCAccessExecutionPermissions",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSubnets",
                "ec2:DeleteNetworkInterface",
                "ec2:AssignPrivateIpAddresses",
                "ec2:UnassignPrivateIpAddresses"
            ],
            "Resource": "*"
        },
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
                "arn:aws:s3:::opxs.v1.${var.run_mode}.image-convert/*"
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

resource "aws_iam_role_policy_attachment" "opxs_batch_image_convert_lambda_policy_attachment" {
  role       = aws_iam_role.opxs_batch_image_convert_lambda_role.name
  policy_arn = aws_iam_policy.opxs_batch_image_convert_lambda_policy.arn
}

resource "aws_cloudwatch_log_group" "opxs_batch_image_convert_lambda_log_group" {
  name              = "/aws/lambda/${local.opxs_batch_image_convert_lambda_name}"
  retention_in_days = 3
}
