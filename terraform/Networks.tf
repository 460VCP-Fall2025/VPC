# -----------------------------
# Internet Gateway (for Public)
# -----------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "460VPC-igw"
  }
}

# -----------------------------
# Route Tables
# -----------------------------
# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "460VPC-rtb-public"
  }
}


# -----------------------------------------
# Private Route Table (for blue + green)
# -----------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "460VPC-private-rt"
  }
}
# -----------------------------------------
# Elastic IP for NAT Gateway
# -----------------------------------------
resource "aws_eip" "nat_eip" {
  vpc = true

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "460VPC-nat-eip"
  }
}

# -----------------------------------------
# NAT Gateway in PUBLIC subnet
# -----------------------------------------
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "460VPC-nat-gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}

# -----------------------------
# Route Table Associations
# -----------------------------
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_assoc_blue" {
  subnet_id      = aws_subnet.private_blue.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_assoc_green" {
  subnet_id      = aws_subnet.private_green.id
  route_table_id = aws_route_table.private.id
}



