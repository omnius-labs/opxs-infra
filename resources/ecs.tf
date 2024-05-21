resource "aws_ecs_cluster" "opxs_api" {
  name = "opxs-api-ecs-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "opxs_api" {
  cluster_name       = aws_ecs_cluster.opxs_api.name
  capacity_providers = [aws_ecs_capacity_provider.opxs_api.name]
  default_capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = aws_ecs_capacity_provider.opxs_api.name
  }
}

resource "aws_ecs_capacity_provider" "opxs_api" {
  # Currentry, we cannot delete capacity provider. If you exec 'terraform destroy', you can delete resouce only on tfstate.
  name = "opxs-api-ecs-cluster-ec2"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.opxs_api_ecs_asg.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 100
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_service" "opxs_api" {
  name            = "opxs-api-ecs-service"
  task_definition = aws_ecs_task_definition.opxs_api.arn
  cluster         = aws_ecs_cluster.opxs_api.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.opxs_api.name
    weight            = 1
    base              = 0
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.opxs_api.arn
    container_name   = "opxs-api"
    container_port   = 8080
  }
}

resource "aws_ecs_task_definition" "opxs_api" {
  container_definitions    = <<EOF
[
  {
    "name": "opxs-api",
    "image": "${aws_ecr_repository.opxs_api.repository_url}:latest",
    "memory": 128,
    "portMappings": [
      {
        "name": "opxs-api-8080-tcp",
        "containerPort": 8080,
        "hostPort": 0,
        "protocol": "tcp",
        "appProtocol": "http"
      }
    ],
    "essential": true,
    "environment": [
      { "name": "RUN_MODE", "value": "dev" },
      { "name": "RUST_BACKTRACE", "value": "full" },
      { "name": "AWS_REGION", "value": "${var.aws_region}" }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.opxs_api.name}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
EOF
  family                   = "opxs-api-task"
  cpu                      = "128"
  memory                   = "128"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.opxs_api_ecs_tasks_execution.arn
  task_role_arn            = aws_iam_role.opxs_api_ecs_task.arn
}

resource "aws_iam_role" "opxs_api_ecs_tasks_execution" {
  name               = "opxs-api-ecs-tasks-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "opxs_api_ecs_tasks_execution" {
  role       = aws_iam_role.opxs_api_ecs_tasks_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "opxs_api_ecs_task" {
  name               = "opxs-api-ecs-task-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "opxs_api_ecs_task" {
  role       = aws_iam_role.opxs_api_ecs_task.name
  policy_arn = aws_iam_policy.opxs_api_ecs_task.arn
}

resource "aws_iam_policy" "opxs_api_ecs_task" {
  name   = "opxs-api-ecs-tasks-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "${aws_secretsmanager_secret.opxs.id}"
    },
    {
      "Effect": "Allow",
      "Action": "sqs:SendMessage",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::opxs.v1.${var.run_mode}.image-convert/*"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "opxs_api" {
  name              = "/aws/opxs-api-task/task-group"
  retention_in_days = 3
}
