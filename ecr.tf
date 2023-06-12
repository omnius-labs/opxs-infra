resource "aws_ecr_repository" "opxs_api" {
  name = "opxs-api"
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
