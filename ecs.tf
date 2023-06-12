resource "aws_ecs_cluster" "opxs-api-cluster" {
  name = "opxs-api-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "opxs-api-cluster-ec2" {
  cluster_name       = aws_ecs_cluster.opxs-api-cluster.name
  capacity_providers = [aws_ecs_capacity_provider.opxs-api-cluster-ec2.name]
  default_capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = aws_ecs_capacity_provider.opxs-api-cluster-ec2.name
  }
}

resource "aws_ecs_capacity_provider" "opxs-api-cluster-ec2" {
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

################################################
## Service: opxs-api
################################################

resource "aws_ecs_service" "opxs-api" {
  name            = "opxs-api"
  task_definition = aws_ecs_task_definition.opxs-api.arn
  cluster         = aws_ecs_cluster.opxs-api-cluster.arn
  desired_count   = 0

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.opxs-api-cluster-ec2.name
    weight            = 1
    base              = 0
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_ecs_task_definition" "opxs-api" {
  container_definitions    = <<EOF
[
  {
    "name": "opxs-api",
    "image": "ubuntu:latest",
    "memory": 128,
    "essential": true,
    "command": ["tail", "-f", "/dev/null"]
  }
]
EOF
  family                   = "test-task"
  cpu                      = "128"
  memory                   = "128"
  requires_compatibilities = ["EC2"]
}
