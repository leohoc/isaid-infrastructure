data "aws_availability_zones" "available" {
}

# creating isaid project vpc
resource "aws_vpc" "isaid-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    "Name"                                      = "isaid-cluster-vpc"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

# creating two subnets in the vpc
resource "aws_subnet" "isaid-vpc-subnets" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.isaid-vpc.id

  tags = {
    "Name"                                      = "isaid-cluster-vpc-subnet${count.index}"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

# creating an internet gateway in the vpc
resource "aws_internet_gateway" "isaid-vpc-internet-gateway" {
  vpc_id = aws_vpc.isaid-vpc.id

  tags = {
    Name = "isaid-cluster-vpc-internet-gateway"
  }
}

# creating routes in the vpc
resource "aws_route_table" "isaid-vpc-route-table" {
  vpc_id = aws_vpc.isaid-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.isaid-vpc-internet-gateway.id
  }
}

# associating routes with vpc subnets
resource "aws_route_table_association" "isaid-vpc-subnets-route-association" {
  count = 2

  subnet_id      = aws_subnet.isaid-vpc-subnets[count.index].id
  route_table_id = aws_route_table.isaid-vpc-route-table.id
}