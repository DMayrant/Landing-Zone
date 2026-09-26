# eu-west-2-tgw.tf

resource "aws_subnet" "eu_west_2_tgw" {
  provider = aws.euro
  count    = length(var.eu_west_2_availability_zones)

  vpc_id                  = aws_vpc.dr_vpc.id
  cidr_block              = var.eu_west_2_tgw_subnet_cidrs[count.index]
  availability_zone       = var.eu_west_2_availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "eu-west-2-tgw-${var.eu_west_2_availability_zones[count.index]}"
  })
}

resource "aws_ec2_transit_gateway" "eu_west_2" {
  provider = aws.euro

  description                     = "Landing zone eu-west-2 transit gateway"
  amazon_side_asn                 = 64513
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = merge(local.common_tags, {
    Name = "landing-zone-eu-west-2-tgw"
  })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "eu_west_2_vpc" {
  provider = aws.euro

  transit_gateway_id = aws_ec2_transit_gateway.eu_west_2.id
  vpc_id             = aws_vpc.dr_vpc.id
  subnet_ids         = aws_subnet.eu_west_2_tgw[*].id

  dns_support                                     = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(local.common_tags, {
    Name = "landing-zone-eu-west-2-vpc-attachment"
  })
}

resource "aws_ec2_transit_gateway_route_table" "eu_west_2" {
  provider = aws.euro

  transit_gateway_id = aws_ec2_transit_gateway.eu_west_2.id

  tags = merge(local.common_tags, {
    Name = "landing-zone-eu-west-2-tgw-rt"
  })
}

#########################################
# Route table association and propagation
#########################################
resource "aws_ec2_transit_gateway_route_table_association" "eu_west_2_vpc" {
  provider = aws.euro

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.eu_west_2_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.eu_west_2.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "eu_west_2_vpc" {
  provider = aws.euro

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.eu_west_2_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.eu_west_2.id
}