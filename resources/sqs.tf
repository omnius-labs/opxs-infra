resource "aws_sqs_queue" "opxs_batch_email_send_sqs" {
  name                       = "opxs-batch-email-send-sqs"
  message_retention_seconds  = 60 * 60 * 24 * 4
  visibility_timeout_seconds = 60 * 15 + 10
  receive_wait_time_seconds  = 5

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.opxs_batch_email_send_error_sqs.arn
    maxReceiveCount     = 2
  })
}

resource "aws_sqs_queue" "opxs_batch_email_send_error_sqs" {
  name                       = "opxs-batch-email-send-error-sqs"
  message_retention_seconds  = 60 * 60 * 24 * 4
  visibility_timeout_seconds = 60 * 15 + 10
  receive_wait_time_seconds  = 5
}

resource "aws_lambda_event_source_mapping" "opxs_batch_email_send_lambda" {
  batch_size       = 1
  event_source_arn = aws_sqs_queue.opxs_batch_email_send_sqs.arn
  function_name    = aws_lambda_function.opxs_batch_email_send_lambda.arn
}

resource "aws_sqs_queue" "opxs_batch_image_convert_sqs" {
  name                       = "opxs-batch-image-convert-sqs"
  message_retention_seconds  = 60 * 60 * 24 * 4
  visibility_timeout_seconds = 60 * 15 + 10
  receive_wait_time_seconds  = 5
  policy                     = <<EOF
{
  "Version": "2012-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__owner_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_account_id}:root"
      },
      "Action": "SQS:*",
      "Resource": "arn:aws:sqs:us-east-1:${var.aws_account_id}:opxs-batch-image-convert-sqs"
    },
    {
      "Sid": "example-statement-ID",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "SQS:SendMessage",
      "Resource": "arn:aws:sqs:us-east-1:${var.aws_account_id}:opxs-batch-image-convert-sqs",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${var.aws_account_id}"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:s3:::opxs.v1.${var.run_mode}.image-convert"
        }
      }
    }
  ]
}
EOF

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.opxs_batch_image_convert_error_sqs.arn
    maxReceiveCount     = 2
  })
}

resource "aws_sqs_queue" "opxs_batch_image_convert_error_sqs" {
  name                       = "opxs-batch-image-convert-error-sqs"
  message_retention_seconds  = 60 * 60 * 24 * 4
  visibility_timeout_seconds = 60 * 15 + 10
  receive_wait_time_seconds  = 5
}

resource "aws_lambda_event_source_mapping" "opxs_batch_image_convert_lambda" {
  batch_size       = 1
  event_source_arn = aws_sqs_queue.opxs_batch_image_convert_sqs.arn
  function_name    = aws_lambda_function.opxs_batch_image_convert_lambda.arn
}
