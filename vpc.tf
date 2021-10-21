/*==== The VPC ======*/
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
      Name        = "${var.environment}-vpc"
      Environment = "${var.environment}"
    }
}

/*==== The Subnets ======*/
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)

  tags = {
      Name        = "${var.environment}-${element(var.availability_zones, count.index)}-private-subnet"
      Environment = "${var.environment}"
    }
}

/*==== The IGW ======*/
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
}

/* Routing table for private subnet */
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-private-route-table"
    Environment = "${var.environment}"
  }
}

/* Route table association*/
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}

# ECR VPC endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = "${aws_vpc.vpc.id}"
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_subnet.*.id

  security_group_ids = [
    "${aws_security_group.ecs_tasks.id}",
  ]

  tags = {
    Name = "ECR Docker VPC Endpoint Interface - ${var.environment}"
    Environment = var.environment
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = "${aws_vpc.vpc.id}"
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_subnet.*.id

  security_group_ids = [
    "${aws_security_group.ecs_tasks.id}",
  ]

  tags = {
    Name = "ECR Docker VPC Endpoint Interface - ${var.environment}"
    Environment = var.environment
  }
}

# S3 VPC endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = "${aws_vpc.vpc.id}"
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_rt.id]

  tags = {
    Name = "S3 VPC Endpoint Gateway - ${var.environment}"
    Environment = var.environment
  }
}


# CloudWatch
resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id              = "${aws_vpc.vpc.id}"
  service_name        = "com.amazonaws.ap-south-1.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_subnet.*.id
  private_dns_enabled = true

  security_group_ids = [
    "${aws_security_group.ecs_tasks.id}",
  ]

  tags = {
    Name = "CloudWatch VPC Endpoint Interface - ${var.environment}"
    Environment = var.environment
  }
}
