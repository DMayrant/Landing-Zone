# us-east-1-tgw.tf

resource "aws_subnet" "us_east_1_tgw" {
  provider = aws.us_east_1
  count    = length(var.us_east_1_availability_zones)

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.us_east_1_tgw_subnet_cidrs[count.index]
  availability_zone       = var.us_east_1_availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "us-east-1-tgw-${var.us_east_1_availability_zones[count.index]}"
  })
}

resource "aws_ec2_transit_gateway" "us_east_1" {
  provider = aws.us_east_1

  description                     = "Landing zone hub transit gateway"
  amazon_side_asn                 = 64512
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = merge(local.common_tags, {
    Name = "landing-zone-us-east-1-hub-tgw"
  })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "us_east_1_vpc" {
  provider = aws.us_east_1

  transit_gateway_id = aws_ec2_transit_gateway.us_east_1.id
  vpc_id             = aws_vpc.main_vpc.id
  subnet_ids         = aws_subnet.us_east_1_tgw[*].id

  dns_support                                     = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(local.common_tags, {
    Name = "landing-zone-us-east-1-vpc-attachment"
  })
}

resource "aws_ec2_transit_gateway_route_table" "us_east_1" {
  provider = aws.us_east_1

  transit_gateway_id = aws_ec2_transit_gateway.us_east_1.id

  tags = merge(local.common_tags, {
    Name = "landing-zone-us-east-1-tgw-rt"
  })
}

#########################################
# Route table association and propagation
#########################################

resource "aws_ec2_transit_gateway_route_table_association" "us_east_1_vpc" {
  provider = aws.us_east_1

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.us_east_1_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_1.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "us_east_1_vpc" {
  provider = aws.us_east_1

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.us_east_1_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_1.id
}