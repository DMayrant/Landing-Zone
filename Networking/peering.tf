#####################################
# Current AWS Account
#####################################
data "aws_caller_identity" "current" {}

#####################################
# US-to-EU Transit Gateway Peering
#####################################
resource "aws_ec2_transit_gateway_peering_attachment" "us_to_eu" {
  provider = aws.us_east_1

  transit_gateway_id      = aws_ec2_transit_gateway.us_east_1.id
  peer_transit_gateway_id = aws_ec2_transit_gateway.eu_west_2.id
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = "eu-west-2"

  tags = merge(local.common_tags, {
    Name = "landing-zone-us-east-1-to-eu-west-2"
  })
}

#####################################
# Accept Peering in eu-west-2
#####################################
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "eu_from_us" {
  provider = aws.euro

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.us_to_eu.id

  tags = merge(local.common_tags, {
    Name = "landing-zone-eu-west-2-from-us-east-1"
  })
}

#####################################
# Peering Route Table Associations
#####################################
# Associate the attachment with both regional transit gateway route tables.
resource "aws_ec2_transit_gateway_route_table_association" "us_peering" {
  provider = aws.us_east_1

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.eu_from_us.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_1.id
}

resource "aws_ec2_transit_gateway_route_table_association" "eu_peering" {
  provider = aws.euro

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.eu_from_us.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.eu_west_2.id
}

#####################################
# Static Transit Gateway Routes
#####################################
# Peering routes do not propagate; route each remote VPC CIDR explicitly.
resource "aws_ec2_transit_gateway_route" "us_to_eu" {
  provider = aws.us_east_1

  destination_cidr_block         = aws_vpc.dr_vpc.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.eu_from_us.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_1.id

  depends_on = [aws_ec2_transit_gateway_route_table_association.us_peering]
}

resource "aws_ec2_transit_gateway_route" "eu_to_us" {
  provider = aws.euro

  destination_cidr_block         = aws_vpc.main_vpc.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.eu_from_us.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.eu_west_2.id

  depends_on = [aws_ec2_transit_gateway_route_table_association.eu_peering]
}

#####################################
# US VPC Subnet Routes to Europe
#####################################
# EU subnet routes already point to the EU transit gateway in eu-west-2-vpc.tf.
resource "aws_route" "us_public_to_eu" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = aws_vpc.dr_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_1.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.us_east_1_vpc]
}

resource "aws_route" "us_private_to_eu" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = aws_vpc.dr_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_1.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.us_east_1_vpc]
}