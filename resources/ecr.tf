resource "aws_ecr_repository" "opxs_api" {
  name = "opxs-api-ecs-ecr"
}

resource "aws_ecr_repository" "opxs_batch_email_send" {
  name = "opxs-batch-email-send-lambda-ecr"
}

resource "aws_ecr_repository" "opxs_batch_email_send_feedback" {
  name = "opxs-batch-email-send-feedback-lambda-ecr"
}

resource "aws_ecr_repository" "opxs_batch_image_convert" {
  name = "opxs-batch-image-convert-lambda-ecr"
}

locals {
  ecr-lifecycle-policy = {
    rules = [
      {
        action = {
          type = "expire"
        }
        description  = "最新のイメージを3つだけ残す"
        rulePriority = 1
        selection = {
          countNumber = 3
          countType   = "imageCountMoreThan"
          tagStatus   = "any"
        }
      },
    ]
  }
}

resource "aws_ecr_lifecycle_policy" "opxs_api" {
  repository = aws_ecr_repository.opxs_api.name
  policy     = jsonencode(local.ecr-lifecycle-policy)
}

resource "aws_ecr_lifecycle_policy" "opxs_batch_email_send" {
  repository = aws_ecr_repository.opxs_batch_email_send.name
  policy     = jsonencode(local.ecr-lifecycle-policy)
}

resource "aws_ecr_lifecycle_policy" "opxs_batch_email_send_feedback" {
  repository = aws_ecr_repository.opxs_batch_email_send_feedback.name
  policy     = jsonencode(local.ecr-lifecycle-policy)
}

resource "aws_ecr_lifecycle_policy" "opxs_batch_image_convert" {
  repository = aws_ecr_repository.opxs_batch_image_convert.name
  policy     = jsonencode(local.ecr-lifecycle-policy)
}
