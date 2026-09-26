output "us_east_1_vpc_id" {
  description = "ID of the us-east-1 VPC"
  value       = aws_vpc.main_vpc.id
}

output "us_east_1_vpc_cidr" {
  description = "CIDR block of the us-east-1 VPC"
  value       = aws_vpc.main_vpc.cidr_block
}

output "us_east_1_public_subnet_ids" {
  description = "Public subnet IDs in us-east-1"
  value       = aws_subnet.public_subnet[*].id
}

output "us_east_1_private_subnet_ids" {
  description = "Private subnet IDs in us-east-1"
  value       = aws_subnet.private_subnet_a[*].id
}

output "us_east_1_tgw_id" {
  description = "ID of the us-east-1 hub Transit Gateway"
  value       = aws_ec2_transit_gateway.us_east_1.id
}

output "us_east_1_tgw_attachment_id" {
  description = "US VPC attachment to the us-east-1 Transit Gateway"
  value       = aws_ec2_transit_gateway_vpc_attachment.us_east_1_vpc.id
}

output "eu_west_2_vpc_id" {
  description = "ID of the eu-west-2 VPC"
  value       = aws_vpc.dr_vpc.id
}

output "eu_west_2_vpc_cidr" {
  description = "CIDR block of the eu-west-2 VPC"
  value       = aws_vpc.dr_vpc.cidr_block
}

output "eu_west_2_public_subnet_ids" {
  description = "Public subnet IDs in eu-west-2"
  value       = aws_subnet.eu-west-2-public_subnet[*].id
}

output "eu_west_2_private_subnet_ids" {
  description = "Private subnet IDs in eu-west-2"
  value       = aws_subnet.eu-west-2-private_subnet_a[*].id
}

output "eu_west_2_tgw_id" {
  description = "ID of the eu-west-2 Transit Gateway"
  value       = aws_ec2_transit_gateway.eu_west_2.id
}

output "eu_west_2_tgw_attachment_id" {
  description = "EU VPC attachment to the eu-west-2 Transit Gateway"
  value       = aws_ec2_transit_gateway_vpc_attachment.eu_west_2_vpc.id
}