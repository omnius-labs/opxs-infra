resource "aws_ecr_repository" "opxs_api_lambda" {
  name = "opxs-api-lambda"
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

resource "aws_ecr_lifecycle_policy" "opxs_api_lambda" {
  repository = aws_ecr_repository.opxs_api_lambda.name
  policy     = jsonencode(local.ecr-lifecycle-policy)
}
