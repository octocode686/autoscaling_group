# Create a VPC ----------------------------------------------------------------
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "main_vpc"
  }
}

# Create 4 Subnets ------------------------------------------------------------
resource "aws_subnet" "terraform_sub1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = lookup(var.cidr_ranges, "public1")
  availability_zone = var.availability_zones.zone_1
  tags = {
    Name = "${lookup(var.subnet_type, "public")}-subnet"
  }
}

resource "aws_subnet" "terraform_sub2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = lookup(var.cidr_ranges, "public2")
  availability_zone = var.availability_zones.zone_2
  tags = {
    Name = "${lookup(var.subnet_type, "public")}--subnet"
  }
}

resource "aws_subnet" "terraform_sub3" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = lookup(var.cidr_ranges, "private1")
  availability_zone = var.availability_zones.zone_1
  tags = {
    Name = lookup(var.subnet_type, "private")
  }
}

resource "aws_subnet" "terraform_sub4" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = lookup(var.cidr_ranges, "private2")
  availability_zone = var.availability_zones.zone_2
  tags = {
    Name = lookup(var.subnet_type, "private")
  }
}

# Create a IGW ----------------------------------------------------------------
resource "aws_internet_gateway" "terraform_gateway" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "terraform_gateway"
  }
}

# Create 2 ElasticIP ---------------------------------------------------------
resource "aws_eip" "terraform_elip" {
  domain = "vpc"
}

resource "aws_eip" "terraform_elip2" {
  domain = "vpc"
}

# Create 2 NAT Gateway --------------------------------------------------------
resource "aws_nat_gateway" "terraform_nat" {
  allocation_id = aws_eip.terraform_elip.id
  subnet_id     = aws_subnet.terraform_sub1.id
  tags = {
    Name = "nat_gateway_2"
  }
}

resource "aws_nat_gateway" "terraform_nat2" {
  allocation_id = aws_eip.terraform_elip2.id
  subnet_id     = aws_subnet.terraform_sub2.id
  tags = {
    Name = "nat_gateway_1"
  }
}

# Create 4 Routing Tables -----------------------------------------------------
resource "aws_route_table" "terraform_route_gateway" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = var.allow_all_traffic_cidr_block
    gateway_id = aws_internet_gateway.terraform_gateway.id
  }
}

resource "aws_route_table" "route_nat" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block     = var.allow_all_traffic_cidr_block
    nat_gateway_id = aws_nat_gateway.terraform_nat.id
  }
}

resource "aws_route_table" "route_nat2" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block     = var.allow_all_traffic_cidr_block
    nat_gateway_id = aws_nat_gateway.terraform_nat2.id
  }
}

# Assosiate Routing Tables ----------------------------------------------------
resource "aws_route_table_association" "terraform_associate1" {
  subnet_id      = aws_subnet.terraform_sub1.id
  route_table_id = aws_route_table.terraform_route_gateway.id
}

resource "aws_route_table_association" "terraform_associate2" {
  subnet_id      = aws_subnet.terraform_sub2.id
  route_table_id = aws_route_table.terraform_route_gateway.id
}

resource "aws_route_table_association" "terraform_associate3" {
  subnet_id      = aws_subnet.terraform_sub3.id
  route_table_id = aws_route_table.route_nat.id
}

resource "aws_route_table_association" "terraform_associate4" {
  subnet_id      = aws_subnet.terraform_sub4.id
  route_table_id = aws_route_table.route_nat.id

}
