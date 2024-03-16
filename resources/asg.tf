data "aws_ssm_parameter" "ecs_optimized_ami" {
  # Get latest ecs optimized ami
  # https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

resource "aws_autoscaling_group" "opxs_api_ecs_asg" {
  name = "opxs-api-ecs-asg"

  max_size = 2
  min_size = 0

  vpc_zone_identifier = module.vpc.private_subnets

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.opxs_api.id
        version            = "$Latest" # https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#version
      }
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity, tag]
  }

  # Interval of scale in/out
  default_cooldown = 60

  # If you enable managedTerminationProtection on capacity provider, you have to enable this.
  # protect_from_scale_in = true
}

resource "aws_launch_template" "opxs_api" {
  name                   = "opxs_api"
  image_id               = data.aws_ssm_parameter.ecs_optimized_ami.value
  vpc_security_group_ids = [aws_security_group.opxs_api_ecs_ec2.id]
  instance_type          = "t3.nano"

  ebs_optimized = true
  user_data = base64encode(<<EOF
#!/bin/bash
echo 'ECS_CLUSTER=opxs-api-ecs-cluster' >> /etc/ecs/ecs.config
EOF
  )

  network_interfaces {
    associate_public_ip_address = false
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "opxs-api-ecs-instance"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "opxs-api-ecs-instance"
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.opxs_ecs_instance.arn
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "opxs_api_ecs_ec2" {
  name   = "opxs-api-ecs-ec2-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.opxs_alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
