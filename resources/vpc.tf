module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "main"
  cidr                 = "10.0.0.0/16"
  azs                  = [var.availability_zone_1, var.availability_zone_2]
  private_subnets      = ["10.0.0.0/24", "10.0.1.0/24"]
  public_subnets       = ["10.0.2.0/24", "10.0.3.0/24"]
  enable_dns_hostnames = true
}

module "nat" {
  source = "int128/nat-instance/aws"

  name                        = "main"
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids
}

resource "aws_internet_gateway" "opxs" {
  vpc_id = aws_vpc.opxs.id
}

resource "aws_route_table" "opxs" {
  vpc_id = module.vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.opxs.id
  }
}

resource "aws_route_table_association" "opxs_public_1" {
  route_table_id = aws_route_table.opxs.id
  subnet_id      = module.vpc.public_subnets[0]
}

resource "aws_route_table_association" "opxs_public_2" {
  route_table_id = aws_route_table.opxs.id
  subnet_id      = module.vpc.public_subnets[1]
}
