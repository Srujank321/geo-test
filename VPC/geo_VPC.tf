provider "aws" {
  region = "ap-southeast-1"
}

#Creating the VPC,name,CIDR and Tags
resource "aws_vpc" "geo-vpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = {
    Name = "geo-vpc"
  }
}

# Creating Public and private Subnets in VPC
resource "aws_subnet" "geo-public-1" {
  vpc_id                  = aws_vpc.geo-vpc.id
  cidr_block              = "192.168.50.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-southeast-1a"

  tags = {
    Name = "geo-public-1"
  }
}

resource "aws_subnet" "geo-public-2" {
  vpc_id                  = aws_vpc.geo-vpc.id
  cidr_block              = "192.168.51.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-southeast-1b"

  tags = {
    Name = "geo-public-2"
  }
}

resource "aws_subnet" "geo-private-1" {
  vpc_id                  = aws_vpc.geo-vpc.id
  cidr_block              = "192.168.52.0/24"
  availability_zone       = "ap-southeast-1a"

  tags = {
    Name = "geo-private-1"
  }
}

resource "aws_subnet" "geo-private-2" {
  vpc_id                  = aws_vpc.geo-vpc.id
  cidr_block              = "192.168.53.0/24"
  availability_zone       = "ap-southeast-1b"

  tags = {
    Name = "geo-private-2"
  }
}

# Creating Internet Gateway in AWS VPC
resource "aws_internet_gateway" "geo-igw" {
  vpc_id = aws_vpc.geo-vpc.id

  tags = {
    Name = "geo-igw"
  }
}

# Creating NAT Gateway
resource "aws_nat_gateway" "geo-nat" {
  subnet_id     = aws_subnet.geo-public-1.id

  tags = {
    Name = "geo-nat"
  }
}

resource "aws_internet_gateway_attachment" "igwattach" {
  internet_gateway_id = aws_internet_gateway.geo-igw.id
  vpc_id              = aws_vpc.geo-vpc.id
}

# Creating public Route Table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.geo-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.geo-igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Creating private Route Table
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.geo-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.geo-nat.id
  }

  tags = {
    Name = "private-rt"
  }
}

# Creating Route Associations public subnets
resource "aws_route_table_association" "public-1-a" {
  subnet_id      = aws_subnet.geo-public-1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-2-a" {
  subnet_id      = aws_subnet.geo-public-2.id
  route_table_id = aws_route_table.public-rt.id
}

# Creating Route Associations private subnets
resource "aws_route_table_association" "private-1-a" {
  subnet_id      = aws_subnet.geo-private-1.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-2-a" {
  subnet_id      = aws_subnet.geo-private-2.id
  route_table_id = aws_route_table.private-rt.id
}