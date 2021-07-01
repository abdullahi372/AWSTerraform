resource "aws_vpc" "ws-VPC" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "ws-VPC"
  }
}


resource "aws_internet_gateway" "ws-igw" {
  vpc_id = aws_vpc.ws-VPC.id
  tags = {
    Name = "Web Server VPC"
  }
}


resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.ws-VPC.id
  cidr_block              = element(var.subnets_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "ws-public_rt" {
  vpc_id = aws_vpc.ws-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ws-igw.id
  }
  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.ws-public_rt.id
}


resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.ws-VPC.id
  cidr_block = "10.0.3.0/24"
  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_route_table" "ws-private_rt" {
  vpc_id = aws_vpc.ws-VPC.id

}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.ws-private_rt.id
}

resource "aws_eip" "ws-eIP" {
  vpc = true
}



resource "aws_security_group" "ws-sg" {
  vpc_id = aws_vpc.ws-VPC.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Allow HTTP access"
  }
}
