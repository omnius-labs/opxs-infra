data "aws_iam_policy" "AmazonEC2ContainerServiceforEC2Role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role" "opxs-ecs-instance-role" {
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

resource "aws_iam_role_policy_attachment" "opxs-ecs-instance-role" {
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerServiceforEC2Role.arn
  role       = aws_iam_role.opxs-ecs-instance-role.name
}

resource "aws_iam_instance_profile" "opxs-ecs-instance-role" {
  role = aws_iam_role.opxs-ecs-instance-role.name
}
