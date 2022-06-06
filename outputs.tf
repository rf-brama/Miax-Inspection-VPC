# VPC
output "module_vpc1_vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc1.vpc_id
}
output "module_vpc2_vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc2.vpc_id
}
output "module_vpc3_vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc3.vpc_id
}
output "module_vpc4_vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc4.vpc_id
}

# Subnets
output "module_vpc1_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc1.private_subnets
}
output "module_vpc2_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc2.private_subnets
}
output "module_vpc3_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc3.private_subnets
}
output "module_vpc4_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc4.private_subnets
}

output "module_vpc1_public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc1.public_subnets
}

output "module_vpc1_database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc1.database_subnets
}

output "module_vpc1_transitgateway_subnets" {
  description = "List of IDs of elasticache subnets"
  value       = aws_subnet.private_subnet
}

output "module_vpc1_nat_subnets" {
  description = "List of IDs of elasticache subnets"
  value       = aws_subnet.public_subnet
}

# NAT gateways
output "module_vpc1_nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc1.nat_public_ips
}


# Customer Gateway
output "module_vpc1_cgw_ids" {
  description = "List of IDs of Customer Gateway"
  value       = module.vpc1.cgw_ids
}

output "module_vpc1_this_customer_gateway" {
  description = "Map of Customer Gateway attributes"
  value       = module.vpc1.this_customer_gateway
}

#Transit Gateway ID
output "transit_gateway" {
  description = "Map of Customer Gateway attributes"
  value       = aws_ec2_transit_gateway.tgw
}

#Internet Gateway ID
output "internet_gateway" {
  description = "Map of Customer Gateway attributes"
  value       = module.vpc1.igw_id
}