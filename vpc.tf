resource "aws_vpc" "opxs" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "opxs_public_1a" {
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  vpc_id                  = aws_vpc.opxs.id
  map_public_ip_on_launch = true
}

resource "aws_subnet" "opxs_public_1c" {
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1c"
  vpc_id                  = aws_vpc.opxs.id
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "opxs" {
  vpc_id = aws_vpc.opxs.id
}

resource "aws_route_table" "opxs" {
  vpc_id = aws_vpc.opxs.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.opxs.id
  }
}

resource "aws_route_table_association" "opxs_public_1a" {
  route_table_id = aws_route_table.opxs.id
  subnet_id      = aws_subnet.opxs_public_1a.id
}

resource "aws_route_table_association" "opxs_public_1c" {
  route_table_id = aws_route_table.opxs.id
  subnet_id      = aws_subnet.opxs_public_1c.id
}

resource "aws_security_group" "opxs_vpc" {
  name   = "opxs-vpc-sg"
  vpc_id = aws_vpc.opxs.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ingress_from_cloudfront_sg_rule" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  security_group_id = aws_security_group.opxs_vpc.id
}

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}
