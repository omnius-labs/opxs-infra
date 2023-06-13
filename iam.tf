resource "aws_iam_role" "opxs_ecs_instance_role" {
  name               = "opxs-ecs-instance-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "opxs_ecs_instance_role" {
  role       = aws_iam_role.opxs_ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "opxs_ecs_instance_role" {
  role = aws_iam_role.opxs_ecs_instance_role.name
}

resource "aws_iam_role" "opxs_api_ecs_tasks_execution_role" {
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

resource "aws_iam_role_policy_attachment" "opxs_api_ecs_tasks_execution_role" {
  role       = aws_iam_role.opxs_api_ecs_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
