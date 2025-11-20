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

# Private route table (local-only)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # AWS automatically provides a local route,
  # so we don't add any routes manually yet

  tags = {
    Name = "460VPC-rtb-private"
  }
}

# -----------------------------
# Route Table Associations
# -----------------------------
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_assoc_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_assoc_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

