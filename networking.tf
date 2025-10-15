#  VPC principal
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.aws_common_tags,
    {
      Name = "main-vpc"
    }
  )
}

# public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"

  tags = merge(
    local.aws_common_tags,
    {
      Name = "public-subnet"
    }
  )
}

# private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = merge(
    local.aws_common_tags,
    {
      Name = "private-subnet"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.aws_common_tags,
    {
      Name = "main-igw"
    }
  )
}

# NAT Gateway
resource "aws_eip" "nat" {
  tags = merge(
    local.aws_common_tags,
    {
      Name = "main-nat-eip"
    }
  )
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = merge(
    local.aws_common_tags,
    {
      Name = "main-nat"
    }
  )
}

# Route table for the public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(
    local.aws_common_tags,
    {
      Name = "public-rt"
    }
  )
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Route table for the private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(
    local.aws_common_tags,
    {
      Name = "private-rt"
    }
  )
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
