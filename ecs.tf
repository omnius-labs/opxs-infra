resource "aws_ecs_cluster" "opxs_api_cluster" {
  name = "opxs-api-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "opxs_api_cluster_ec2" {
  cluster_name       = aws_ecs_cluster.opxs_api_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.opxs_api_cluster_ec2.name]
  default_capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = aws_ecs_capacity_provider.opxs_api_cluster_ec2.name
  }
}

resource "aws_ecs_capacity_provider" "opxs_api_cluster_ec2" {
  # Currentry, we cannot delete capacity provider. If you exec 'terraform destroy', you can delete resouce only on tfstate.
  name = "opxs-api-cluster-ec2"

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
  name            = "opxs-api"
  task_definition = aws_ecs_task_definition.opxs_api.arn
  cluster         = aws_ecs_cluster.opxs_api_cluster.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.opxs_api_cluster_ec2.name
    weight            = 1
    base              = 0
  }

  lifecycle {
    ignore_changes = [task_definition]
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
        "hostPort": 8080,
        "protocol": "tcp",
        "appProtocol": "http"
      }
    ],
    "essential": true,
    "environment": [
      { "name": "RUN_MODE", "value": "dev" },
      { "name": "RUST_BACKTRACE", "value": "1" }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.opxs_api.name}",
        "awslogs-region": "${var.region}",
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

resource "aws_cloudwatch_log_group" "opxs_api" {
  name              = "/aws/opxs-api/task-group"
  retention_in_days = 3
}
