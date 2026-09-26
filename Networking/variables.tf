variable "us_east_1_availability_zones" {
  description = "Availability Zones for the us-east-1 VPC"
  type        = list(string)
}

variable "us_east_1_public_subnet_cidrs" {
  description = "Public subnet CIDRs for us-east-1, ordered by Availability Zone"
  type        = list(string)
}

variable "us_east_1_private_subnet_cidrs" {
  description = "Private subnet CIDRs for us-east-1, ordered by Availability Zone"
  type        = list(string)
}

variable "us_east_1_tgw_subnet_cidrs" {
  description = "Transit Gateway attachment subnet CIDRs for us-east-1"
  type        = list(string)
}

variable "eu_west_2_availability_zones" {
  description = "Availability Zones for the eu-west-2 VPC"
  type        = list(string)
}

variable "eu_west_2_public_subnet_cidrs" {
  description = "Public subnet CIDRs for eu-west-2, ordered by Availability Zone"
  type        = list(string)
}

variable "eu_west_2_private_subnet_cidrs" {
  description = "Private subnet CIDRs for eu-west-2, ordered by Availability Zone"
  type        = list(string)
}

variable "eu_west_2_tgw_subnet_cidrs" {
  description = "Transit Gateway attachment subnet CIDRs for eu-west-2"
  type        = list(string)
}