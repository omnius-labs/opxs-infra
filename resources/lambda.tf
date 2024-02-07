
# resource "aws_iam_role" "opxs_batch_email_send_lambda_role" {
#   name = "opxs-batch-email-send-lambda-role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_policy" "opxs_batch_email_send_lambda_policy" {
#   name   = "opxs-batch-email-send-lambda-policy"
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "secretsmanager:GetSecretValue"
#       ],
#       "Resource": "${aws_secretsmanager_secret.opxs_api.id}"
#     },
#     {
#       "Effect": "Allow",
#       "Action": "sqs:SendMessage",
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "s3:PutObject",
#         "s3:GetObject"
#       ],
#       "Resource": "arn:aws:s3:::opxs.v1.dev.image-convert/*"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "opxs_batch_email_send_lambda_policy_attachment" {
#   role       = aws_iam_role.opxs_batch_email_send_lambda_role
#   policy_arn = aws_iam_policy.opxs_batch_email_send_lambda_policy
# }

# resource "aws_cloudwatch_log_group" "opxs_batch_email_send_lambda_log_group" {
#   name              = "/aws/lambda/${aws_lambda_function.opxs_batch_email_send_lambda.function_name}"
#   retention_in_days = 3
# }
