resource "aws_lambda_function" "opxs_batch_email_send_lambda" {
  function_name = "opxs-batch-email-send-lambda"
  role          = aws_iam_role.opxs_batch_email_send_lambda_role.arn
  package_type  = "Image"
  image_uri     = aws_ecr_repository.opxs_batch_email_send.repository_url
  memory_size   = 128
  timeout       = 60
  environment {
    variables = {
      RUN_MODE       = var.run_mode
      RUST_BACKTRACE = "full"
    }
  }
  ephemeral_storage {
    size = 512
  }
  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.opxs_lambda.id]
  }

}

resource "aws_iam_role" "opxs_batch_email_send_lambda_role" {
  name = "opxs-batch-email-send-lambda-role"

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
            "Resource": "${aws_secretsmanager_secret.opxs_api.id}"
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
  name              = "/aws/lambda/${aws_lambda_function.opxs_batch_email_send_lambda.function_name}"
  retention_in_days = 3
}

resource "aws_lambda_function" "opxs_batch_email_send_feedback_lambda" {
  function_name = "opxs-batch-email-send-feedback-lambda"
  role          = aws_iam_role.opxs_batch_email_send_feedback_lambda_role.arn
  package_type  = "Image"
  image_uri     = aws_ecr_repository.opxs_batch_email_send_feedback.repository_url
  memory_size   = 128
  timeout       = 60
  environment {
    variables = {
      RUN_MODE       = var.run_mode
      RUST_BACKTRACE = "full"
    }
  }
  ephemeral_storage {
    size = 512
  }
  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.opxs_lambda.id]
  }

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
            "Resource": "${aws_secretsmanager_secret.opxs_api.id}"
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
  name              = "/aws/lambda/${aws_lambda_function.opxs_batch_email_send_feedback_lambda.function_name}"
  retention_in_days = 3
}

resource "aws_lambda_function" "opxs_batch_image_convert_lambda" {
  function_name = "opxs-batch-image-convert-lambda"
  role          = aws_iam_role.opxs_batch_image_convert_lambda_role.arn
  package_type  = "Image"
  image_uri     = aws_ecr_repository.opxs_batch_image_convert.repository_url
  memory_size   = 1024
  timeout       = 180
  environment {
    variables = {
      RUN_MODE       = var.run_mode
      RUST_BACKTRACE = "full"
    }
  }
  ephemeral_storage {
    size = 512
  }
  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.opxs_lambda.id]
  }

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
                "arn:aws:s3:::opxs.v1.dev.image-convert/*"
            ]
        },
		{
			"Action": [
				"secretsmanager:GetSecretValue"
			],
			"Effect": "Allow",
            "Resource": "${aws_secretsmanager_secret.opxs_api.id}"
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
  name              = "/aws/lambda/${aws_lambda_function.opxs_batch_image_convert_lambda.function_name}"
  retention_in_days = 3
}

resource "aws_security_group" "opxs_lambda" {
  name   = "opxs-lambda-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
