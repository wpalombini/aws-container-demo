# Create a VPC
resource "aws_vpc" "container-demo-vpc" {
  cidr_block           = "14.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "container-demo-vpc"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "container-demo-igw" {
  vpc_id = aws_vpc.container-demo-vpc.id

  tags = {
    Name = "container-demo-igw"
  }
}

# Create a public subnet a
resource "aws_subnet" "container-demo-subnet-public-a" {
  vpc_id            = aws_vpc.container-demo-vpc.id
  cidr_block        = "14.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "container-demo-public-subnet-a"
  }
}

# Create a public subnet b
resource "aws_subnet" "container-demo-subnet-public-b" {
  vpc_id            = aws_vpc.container-demo-vpc.id
  cidr_block        = "14.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "container-demo-public-subnet-b"
  }
}

# Create a route table
resource "aws_route_table" "container-demo-route-public" {
  vpc_id = aws_vpc.container-demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.container-demo-igw.id
  }

  tags = {
    Name = "container-demo-public-route-table"
  }
}

# Associate the route table with the public a subnet
resource "aws_route_table_association" "container-demo-rta-public-a" {
  subnet_id      = aws_subnet.container-demo-subnet-public-a.id
  route_table_id = aws_route_table.container-demo-route-public.id
}

# Associate the route table with the public b subnet
resource "aws_route_table_association" "container-demo-rta-public-b" {
  subnet_id      = aws_subnet.container-demo-subnet-public-b.id
  route_table_id = aws_route_table.container-demo-route-public.id
}

data "aws_availability_zones" "available" {}

# Output the VPC ID
output "vpc_id" {
  value = aws_vpc.container-demo-vpc.id
}

# Output the public subnet a ID
output "public_subnet_id_a" {
  value = aws_subnet.container-demo-subnet-public-a.id
}

# Output the public subnet b ID
output "public_subnet_id_b" {
  value = aws_subnet.container-demo-subnet-public-b.id
}
