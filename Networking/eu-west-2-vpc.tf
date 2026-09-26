resource "aws_vpc" "dr_vpc" {
  provider = aws.euro

  cidr_block           = "10.106.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "eu-west-2-dr-vpc"
  })
}

resource "aws_subnet" "eu-west-2-public_subnet" {
  provider = aws.euro
  count    = length(var.eu_west_2_availability_zones)

  vpc_id                  = aws_vpc.dr_vpc.id
  cidr_block              = var.eu_west_2_public_subnet_cidrs[count.index]
  availability_zone       = var.eu_west_2_availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "eu-west-2-public-${var.eu_west_2_availability_zones[count.index]}"
  })
}

resource "aws_subnet" "eu-west-2-private_subnet_a" {
  provider = aws.euro
  count    = length(var.eu_west_2_availability_zones)

  vpc_id                  = aws_vpc.dr_vpc.id
  cidr_block              = var.eu_west_2_private_subnet_cidrs[count.index]
  availability_zone       = var.eu_west_2_availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "eu-west-2-private-${var.eu_west_2_availability_zones[count.index]}"
  })
}

resource "aws_internet_gateway" "eu-west-2-igw" {
  provider = aws.euro
  vpc_id   = aws_vpc.dr_vpc.id

  tags = merge(local.common_tags, {
    Name = "eu-west-2-igw"
  })
}

resource "aws_route_table" "eu-west-2-public-table" {
  provider = aws.euro
  vpc_id   = aws_vpc.dr_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eu-west-2-igw.id
  }

  route {
    cidr_block         = "10.96.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.eu_west_2.id
  }

  tags = merge(local.common_tags, {
    Name = "eu-west-2-public-rt"
  })
}

resource "aws_route_table" "eu-west-2-private" {
  provider = aws.euro
  vpc_id   = aws_vpc.dr_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eu-west-2-ipv4_NAT.id
  }

  route {
    cidr_block         = "10.96.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.eu_west_2.id
  }

  tags = merge(local.common_tags, {
    Name = "eu-west-2-private-rt"
  })
}

resource "aws_route_table_association" "eu-west-2-public" {
  provider = aws.euro
  count    = length(aws_subnet.eu-west-2-public_subnet)

  subnet_id      = aws_subnet.eu-west-2-public_subnet[count.index].id
  route_table_id = aws_route_table.eu-west-2-public-table.id
}

resource "aws_route_table_association" "eu-west-2-private" {
  provider = aws.euro
  count    = length(aws_subnet.eu-west-2-private_subnet_a)

  subnet_id      = aws_subnet.eu-west-2-private_subnet_a[count.index].id
  route_table_id = aws_route_table.eu-west-2-private.id
}

resource "aws_eip" "eu-west-2-NAT" {
  provider = aws.euro
  domain   = "vpc"
}

resource "aws_nat_gateway" "eu-west-2-ipv4_NAT" {
  provider = aws.euro

  allocation_id = aws_eip.eu-west-2-NAT.id
  subnet_id     = aws_subnet.eu-west-2-public_subnet[0].id

  depends_on = [aws_internet_gateway.eu-west-2-igw]

  tags = merge(local.common_tags, {
    Name = "eu-west-2-nat-gateway"
  })
}