resource "aws_vpc" "vpc_main" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true  

  tags = {
    Name = "${var.name}-${var.env}"
    Environment = var.env
  }
}

resource "aws_subnet" "subnetA" {
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = "10.10.1.0/24"

  tags = {
    Name = "Subnet-A"
    Environment = var.env
  }
}

resource "aws_subnet" "subnetB" {
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = "10.10.2.0/24"

  tags = {
    Name = "Subnet-B"
    Environment = var.env
  }
}

resource "aws_subnet" "subnetC" {
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = "10.10.3.0/24"

  tags = {
    Name = "Subnet-C"
    Environment = var.env
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "myIGW"
    Environment = var.env
  }
}

resource "aws_route_table" "public_RT" {
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  
  tags = {
    Name = "publicRT"
    Environment = var.env
  }
}

resource "aws_route_table" "private_RT" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "privateRT"
    Environment = var.env
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnetA.id
  route_table_id = aws_route_table.public_RT.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnetB.id
  route_table_id = aws_route_table.public_RT.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.subnetC.id
  route_table_id = aws_route_table.private_RT.id
}
