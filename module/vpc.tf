resource "aws_vpc" "opxs" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "opxs_public_1" {
  cidr_block              = "10.0.0.0/24"
  availability_zone       = var.subnet_public_1
  vpc_id                  = aws_vpc.opxs.id
  map_public_ip_on_launch = true
}

resource "aws_subnet" "opxs_public_2" {
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.subnet_public_2
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

resource "aws_route_table_association" "opxs_public_1" {
  route_table_id = aws_route_table.opxs.id
  subnet_id      = aws_subnet.opxs_public_1.id
}

resource "aws_route_table_association" "opxs_public_2" {
  route_table_id = aws_route_table.opxs.id
  subnet_id      = aws_subnet.opxs_public_2.id
}
