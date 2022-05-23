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
  private_subnets      = ["10.248.11.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
    

  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = "1"
     Name = "ALB-Public-Miax"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = "1"
     Name = "FW-Private-Miax"
  }
  tags = {
    Owner       = "user"
    Environment = "Inspection"
  }     
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id             = "${module.vpc1.vpc_id}"
  cidr_block         = "10.248.13.0/24"
  availability_zone  = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "NAT-public-subnet"
    Environment = "Inspection"
  }
}
 
# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id             = "${module.vpc1.vpc_id}"
  cidr_block         = "10.248.12.0/24"
  availability_zone  = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name        = "Transit-Private-subnet"
    Environment = "Inspection"
  }
}

#Creating private Route for TG subnet
resource "aws_route_table" "transit_private" {
  vpc_id = "${module.vpc1.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = "vpce-05e5eca677ac5e145"
  }
  route {
    cidr_block = "10.248.8.0/24"
    vpc_endpoint_id = "vpce-05e5eca677ac5e145"
  }
  route {
    cidr_block = "10.248.10.0/24"
    vpc_endpoint_id = "vpce-05e5eca677ac5e145"
  }
  route {
    cidr_block = "10.248.9.0/24"
    vpc_endpoint_id = "vpce-05e5eca677ac5e145"
  }       

  tags = {
    Name = "Ingress-VPC-MIAX-TGW-RT1"
  }
}

resource "aws_route_table" "nat_private" {
  vpc_id = "${module.vpc1.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-0ce178f112d05eed6"
  }
  route {
    cidr_block = "10.248.16.0/20"
    vpc_endpoint_id = "vpce-05e5eca677ac5e145"
  }
  route {
    cidr_block = "10.248.32.0/20"
    vpc_endpoint_id = "vpce-05e5eca677ac5e145"
  }
  route {
    cidr_block = "10.248.48.0/20"
    vpc_endpoint_id = "vpce-05e5eca677ac5e145"
  }       

  tags = {
    Name = "Ingress-VPC-MIAX-NAT-RT1"
  }
}

#Route Table Association
#Public
resource "aws_route_table_association" "us-east-1a-public" {
    count          =  length(aws_subnet.public_subnet) 
    subnet_id = "${aws_subnet.public_subnet.id}"
    route_table_id         = "${aws_route_table.nat_private.id}"
}

#Private
resource "aws_route_table_association" "us-east-1a-private" {
    count          =  length(aws_subnet.private_subnet) 
    subnet_id = "${aws_subnet.private_subnet.id}"
    route_table_id         = "${aws_route_table.transit_private.id}"
}

resource "aws_nat_gateway" "miaxpublic" {
  allocation_id = "eipassoc-0f1220f2165a5ca2e"
  subnet_id     = "${aws_subnet.public_subnet.id}"

  tags = {
    Name = "GK-Infra-NAT1"
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
  single_nat_gateway   = true  

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
  single_nat_gateway   = true  

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
  single_nat_gateway   = true   

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

#Attaching TGW to Subnet Routes

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
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = "${aws_ec2_transit_gateway.tgw.id}"
}
#Adding Routes for VPC
resource "aws_route" "tgw-route-six" {
  route_table_id         = "${module.vpc1.private_route_table_ids[0]}"
  destination_cidr_block = "10.248.16.0/20"
  transit_gateway_id     = "${aws_ec2_transit_gateway.tgw.id}"
}

resource "aws_route" "tgw-route-seven" {
  route_table_id         = "${module.vpc1.private_route_table_ids[0]}"
  destination_cidr_block = "10.248.32.0/20"
  transit_gateway_id     = "${aws_ec2_transit_gateway.tgw.id}"
}

resource "aws_route" "tgw-route-eight" {
  route_table_id         = "${module.vpc1.private_route_table_ids[0]}"
  destination_cidr_block = "10.248.48.0/20"
  transit_gateway_id     = "${aws_ec2_transit_gateway.tgw.id}"
}


#VPC Endpoint Route

/* resource "aws_vpc_endpoint_subnet_association" "miax1" {
  vpc_endpoint_id = "vpce-05e5eca677ac5e145"
  subnet_id       = "${module.vpc1.public_subnets[0]}"
}

resource "aws_vpc_endpoint_subnet_association" "miax2" {
  vpc_endpoint_id = "vpce-05e5eca677ac5e145"
  subnet_id       = "${module.vpc1.public_subnets[1]}"
}
resource "aws_vpc_endpoint_subnet_association" "miax3" {
  vpc_endpoint_id = "vpce-05e5eca677ac5e145"
  subnet_id       = "${module.vpc1.public_subnets[2]}"
} */

/* resource "aws_route_table" "miax1" {
  vpc_id = "${module.vpc1.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = "vpce-05e5eca677ac5e145"
  }
} */

/* resource "aws_vpc_endpoint_route_table_association" "miax1" {
  route_table_id  = "${aws_route_table.transit_private.id}"
  vpc_endpoint_id = "vpce-05e5eca677ac5e145"
} */


#Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {
  auto_accept_shared_attachments = "enable"
  
  tags = {
    Name       = "Main-Miax"
    Environment = "Inspection"
  } 
}

#Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table" "miax" {
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
}

#Transit Gateway Attachments

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1_tgw_attachment" {
  subnet_ids         = aws_subnet.private_subnet.*.id
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id             = "${module.vpc1.vpc_id}"
  transit_gateway_default_route_table_propagation = false
  transit_gateway_default_route_table_association = false
  tags = {
    Name       = "Infra-Transit-Atth-tg"
    Environment = "Inspection"
  } 
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2_tgw_attachment" {
  subnet_ids         = (["${module.vpc2.private_subnets[0]}", "${module.vpc2.private_subnets[1]}", "${module.vpc2.private_subnets[2]}"])
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id             = "${module.vpc2.vpc_id}"
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name       = "QA-Attachment-tg"
    Environment = "Development"
  }   
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc3_tgw_attachment" {
  subnet_ids         = (["${module.vpc3.private_subnets[0]}", "${module.vpc3.private_subnets[1]}", "${module.vpc3.private_subnets[2]}"])
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id             = "${module.vpc3.vpc_id}"
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name       = "Dev-Attachment-tg"
    Environment = "Development"
  } 
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc4_tgw_attachment" {
  subnet_ids         = (["${module.vpc4.private_subnets[0]}", "${module.vpc4.private_subnets[1]}", "${module.vpc4.private_subnets[2]}"])
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id             = "${module.vpc4.vpc_id}"
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name       = "FTB-Attachment-tg"
    Environment = "Development"
  }   
}

#Transit Gateway Association

resource "aws_ec2_transit_gateway_route_table_association" "miax_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.miax.id
}

#Transit Gateway Route#

#VPC to Firewall Route creation
resource "aws_ec2_transit_gateway_route" "route-miax1" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw.association_default_route_table_id
}

#Firewall to VPC Route creation
#QA route
resource "aws_ec2_transit_gateway_route" "route-miax2" {
  destination_cidr_block         = "10.248.32.0/20"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.miax.id
}
#DEV route
resource "aws_ec2_transit_gateway_route" "route-miax3" {
  destination_cidr_block         = "10.248.16.0/20"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc3_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.miax.id
}
#FTB route
resource "aws_ec2_transit_gateway_route" "route-miax4" {
  destination_cidr_block         = "10.248.48.0/20"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc4_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.miax.id
}


/* resource "aws_ec2_transit_gateway_route" "route-miax2" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc3_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw.association_default_route_table_id
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