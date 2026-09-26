resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.96.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = merge(local.common_tags, {
    Name = "US-east-1_VPC"
  })
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.us_east_1_availability_zones)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.us_east_1_public_subnet_cidrs[count.index]
  availability_zone       = var.us_east_1_availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "US-East-1-public_Subnet"
  })
}

resource "aws_subnet" "private_subnet_a" {
  count = length(var.us_east_1_availability_zones)

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.us_east_1_private_subnet_cidrs[count.index]
  availability_zone       = var.us_east_1_availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "us-east-1-private-${var.us_east_1_availability_zones[count.index]}"
  })
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = merge(local.common_tags, {
    Name = "us-east-1_Internet-gateway"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ipv4_NAT.id
  }

}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private_subnet_a)
  subnet_id      = aws_subnet.private_subnet_a[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "NAT" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "ipv4_NAT" {
  allocation_id = aws_eip.NAT.id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.igw]

  tags = merge(local.common_tags, {
    Name = "Us-East-1-NAT-Gateway"
  })
}
