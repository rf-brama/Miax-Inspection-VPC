variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

provider "aws" {
  region = var.region
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = "Ingress-vpc-miax"

  cidr = "10.248.0.0/20"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets       = ["10.248.8.0/24", "10.248.9.0/24", "10.248.10.0/24"]
  private_subnets      = ["10.248.11.0/24", "10.248.12.0/24", "10.248.13.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
    

  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = "1"
     Name = "ALB-Miax"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = "1"
     Name = "FW-Miax"
  }
  tags = {
    Owner       = "user"
    Environment = "Inspection"
  }     
}

module "vpc2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = "QA-vpc-miax"

  cidr = "10.248.32.0/20"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets      = ["10.248.32.0/24", "10.248.33.0/24", "10.248.34.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = "1"
  }
  tags = {
    Owner       = "user"
    Environment = "Quality-Assurance"
  }   

}

module "vpc3" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = "Dev-vpc-miax"

  cidr = "10.248.16.0/20"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets      = ["10.248.16.0/24", "10.248.17.0/24", "10.248.18.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = "1"
  }
  tags = {
    Owner       = "user"
    Environment = "Development"
  }   
}

module "vpc4" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = "FTB-vpc-miax"

  cidr = "10.248.48.0/20"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets      = ["10.248.48.0/24", "10.248.49.0/24", "10.248.50.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = "1"
  }
  tags = {
    Owner       = "user"
    Environment = "FTB"
  }   

}

resource "aws_ec2_transit_gateway" "tgw" {
  auto_accept_shared_attachments = "enable"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1_tgw_attachment" {
  subnet_ids         = (["${module.vpc1.public_subnets[0]}", "${module.vpc1.public_subnets[1]}", "${module.vpc1.public_subnets[2]}"])
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id             = "${module.vpc1.vpc_id}"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2_tgw_attachment" {
  subnet_ids         = (["${module.vpc2.private_subnets[0]}", "${module.vpc2.private_subnets[1]}", "${module.vpc2.private_subnets[2]}"])
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id             = "${module.vpc2.vpc_id}"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc3_tgw_attachment" {
  subnet_ids         = (["${module.vpc3.private_subnets[0]}", "${module.vpc3.private_subnets[1]}", "${module.vpc3.private_subnets[2]}"])
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id             = "${module.vpc3.vpc_id}"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc4_tgw_attachment" {
  subnet_ids         = (["${module.vpc4.private_subnets[0]}", "${module.vpc4.private_subnets[1]}", "${module.vpc4.private_subnets[2]}"])
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id             = "${module.vpc4.vpc_id}"
}

/* resource "aws_ec2_transit_gateway_vpc_attachment" "vpc5_tgw_attachment" {
  subnet_ids         = (["${module.vpc4.firewall_subnets[0]}", "${module.vpc4.firewall_subnets[1]}", "${module.vpc4.firewall_subnets[2]}"])
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id             = "${module.vpc4.vpc_id}"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc6_tgw_attachment" {
  subnet_ids         = (["${module.vpc4.transitgateway_subnets[0]}", "${module.vpc4.transitgateway_subnets[1]}", "${module.vpc4.transitgateway_subnets[2]}"])
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id             = "${module.vpc4.vpc_id}"
} */

/* resource "aws_route" "tgw-route-one" {
  route_table_id         = "${module.vpc1.public_route_table_ids[0]}"
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = "${aws_ec2_transit_gateway.tgw.id}"
}

resource "aws_route" "tgw-route-two" {
  route_table_id         = "${module.vpc1.private_route_table_ids[0]}"
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = "${aws_ec2_transit_gateway.tgw.id}"
} */

resource "aws_route" "tgw-route-three" {
  route_table_id         = "${module.vpc2.private_route_table_ids[0]}"
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = "${aws_ec2_transit_gateway.tgw.id}"
}

resource "aws_route" "tgw-route-four" {
  route_table_id         = "${module.vpc3.private_route_table_ids[0]}"
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = "${aws_ec2_transit_gateway.tgw.id}"
}

resource "aws_route" "tgw-route-five" {
  route_table_id         = "${module.vpc4.private_route_table_ids[0]}"
  destination_cidr_block = "0.0.0.0/8"
  transit_gateway_id     = "${aws_ec2_transit_gateway.tgw.id}"
}
/* resource "aws_route" "tgw-route-six" {
  route_table_id         = "${module.vpc1.firewall_route_table_ids[0]}"
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = "${aws_ec2_transit_gateway.tgw.id}"
} */

/* resource "aws_vpc_endpoint" "miax_infra_endpoint" {
  vpc_id            = "${module.vpc1.vpc_id}"
  service_name      = "com.amazonaws.us-east-1.vpce-svc"
  vpc_endpoint_type = "GatewayLoadBalancer"

  subnet_ids         = (["${module.vpc1.public_subnets[0]}", "${module.vpc1.public_subnets[1]}", "${module.vpc1.public_subnets[2]}"])
  private_dns_enabled = false
} */

/* resource "aws_lb" "this" {
  name               = "Miax-load-balancer"
  load_balancer_type = "network"
  subnets            = (["${module.vpc1.public_subnets[0]}", "${module.vpc1.public_subnets[1]}", "${module.vpc1.public_subnets[2]}"])

  enable_cross_zone_load_balancing = true
} */