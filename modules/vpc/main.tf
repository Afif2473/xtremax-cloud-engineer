locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# VPC & Gateways

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${local.name_prefix}-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${local.name_prefix}-nat-gw"
  }

  depends_on = [aws_internet_gateway.this]
}

# Subnets (Public, Private App, Isolated Private DB)

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name_prefix}-public-${var.azs[count.index]}"
    Tier = "public"
  }
}

resource "aws_subnet" "private_app" {
  count             = length(var.private_app_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name = "${local.name_prefix}-private-app-${var.azs[count.index]}"
    Tier = "private-app"
  }
}

resource "aws_subnet" "private_db" {
  count             = length(var.private_db_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name = "${local.name_prefix}-private-db-${var.azs[count.index]}"
    Tier = "private-db"
  }
}

# Route Tables & Associations

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
  tags = {
    Name = "${local.name_prefix}-private-app-rt"
  }
}
resource "aws_route_table_association" "private_app" {
  count          = length(aws_subnet.private_app)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app.id
}

# Isolated DB Route Table: local VPC routing only

resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.name_prefix}-private-db-rt"
  }
}
resource "aws_route_table_association" "private_db" {
  count          = length(aws_subnet.private_db)
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db.id
}

# Network ACLs

# 1. Public NACL

resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.public[*].id
  tags = {
    Name = "${local.name_prefix}-public-nacl"
  }
}
resource "aws_network_acl_rule" "public_in_http" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}
resource "aws_network_acl_rule" "public_in_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}
resource "aws_network_acl_rule" "public_in_ephemeral" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}
resource "aws_network_acl_rule" "public_out_http" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}
resource "aws_network_acl_rule" "public_out_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}
resource "aws_network_acl_rule" "public_out_ephemeral" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 120
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# 2. Private App NACL

resource "aws_network_acl" "private_app" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.private_app[*].id
  tags = {
    Name = "${local.name_prefix}-private-app-nacl"
  }
}
resource "aws_network_acl_rule" "app_in_http_from_public" {
  count          = length(var.public_subnet_cidrs)
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 100 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.public_subnet_cidrs[count.index]
  from_port      = 80
  to_port        = 80
}
resource "aws_network_acl_rule" "app_in_ephemeral" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}
resource "aws_network_acl_rule" "app_out_mysql_to_db" {
  count          = length(var.private_db_subnet_cidrs)
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 100 + count.index
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.private_db_subnet_cidrs[count.index]
  from_port      = 3306
  to_port        = 3306
}
resource "aws_network_acl_rule" "app_out_http" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}
resource "aws_network_acl_rule" "app_out_https" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 210
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}
resource "aws_network_acl_rule" "app_out_ephemeral_to_public" {
  count          = length(var.public_subnet_cidrs)
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 300 + count.index
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.public_subnet_cidrs[count.index]
  from_port      = 1024
  to_port        = 65535
}

# 3. Private DB NACL (Strictly allows MySQL 3306 from Private App Subnets only)

resource "aws_network_acl" "private_db" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.private_db[*].id
  tags = {
    Name = "${local.name_prefix}-private-db-nacl"
  }
}
resource "aws_network_acl_rule" "db_in_mysql_from_app" {
  count          = length(var.private_app_subnet_cidrs)
  network_acl_id = aws_network_acl.private_db.id
  rule_number    = 100 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.private_app_subnet_cidrs[count.index]
  from_port      = 3306
  to_port        = 3306
}
resource "aws_network_acl_rule" "db_out_ephemeral_to_app" {
  count          = length(var.private_app_subnet_cidrs)
  network_acl_id = aws_network_acl.private_db.id
  rule_number    = 100 + count.index
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.private_app_subnet_cidrs[count.index]
  from_port      = 1024
  to_port        = 65535
}

# Security Groups

# 1. ALB Security Group

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Allow HTTP/HTTPS inbound to ALB and HTTP outbound to EC2"
  vpc_id      = aws_vpc.this.id
  tags = {
    Name = "${local.name_prefix}-alb-sg"
  }
}
resource "aws_vpc_security_group_ingress_rule" "alb_https_in" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS from CloudFront/Public"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_ingress_rule" "alb_http_in" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP (redirected to HTTPS by ALB listener)"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_egress_rule" "alb_to_ec2" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Forward HTTP traffic to WordPress EC2 instances"
  referenced_security_group_id = aws_security_group.ec2.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

# 2. EC2 WordPress Security Group

resource "aws_security_group" "ec2" {
  name        = "${local.name_prefix}-ec2-sg"
  description = "Allow HTTP from ALB only; allow outbound to RDS and HTTPS updates"
  vpc_id      = aws_vpc.this.id
  tags = {
    Name = "${local.name_prefix}-ec2-sg"
  }
}
resource "aws_vpc_security_group_ingress_rule" "ec2_from_alb" {
  security_group_id            = aws_security_group.ec2.id
  description                  = "Allow HTTP traffic exclusively from ALB"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}
resource "aws_vpc_security_group_egress_rule" "ec2_to_rds" {
  security_group_id            = aws_security_group.ec2.id
  description                  = "Allow MySQL traffic to RDS"
  referenced_security_group_id = aws_security_group.rds.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}
resource "aws_vpc_security_group_egress_rule" "ec2_https_out" {
  security_group_id = aws_security_group.ec2.id
  description       = "Allow outbound HTTPS via NAT GW for SSM and package updates"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_egress_rule" "ec2_http_out" {
  security_group_id = aws_security_group.ec2.id
  description       = "Allow outbound HTTP via NAT GW for OS/WordPress repo updates"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# 3. RDS MySQL Security Group

resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-rds-sg"
  description = "Allow MySQL 3306 exclusively from WordPress EC2 instances"
  vpc_id      = aws_vpc.this.id
  tags = {
    Name = "${local.name_prefix}-rds-sg"
  }
}
resource "aws_vpc_security_group_ingress_rule" "rds_from_ec2" {
  security_group_id            = aws_security_group.rds.id
  description                  = "Allow MySQL 3306 exclusively from EC2 Security Group"
  referenced_security_group_id = aws_security_group.ec2.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}
