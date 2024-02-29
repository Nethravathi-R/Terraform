provider "aws" {
    region = "ap-south-1"
  
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.2.0.0/24"

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_subnet" "my-subnet-1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.2.0.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "my-subnet"
  }
}

resource "aws_route_table" "my-route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "my-route-table"
  }
}

resource "aws_route_table_association" "my-route-subnet" {
  subnet_id      = aws_subnet.my-subnet-1.id
  route_table_id = aws_route_table.my-route.id
}

resource "aws_security_group" "my-security-group" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "my-security-groupname"
  }
}

resource "aws_security_group_rule" "inbound" {
  security_group_id = aws_security_group.my-security-group.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks      = [aws_vpc.vpc.cidr_block]
}

resource "aws_security_group_rule" "outbound" {
  security_group_id = aws_security_group.my-security-group.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
}

resource "aws_instance" "ec2-mumbai" {
  ami           = "ami-05ff0b3a7128cd6f8"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my-subnet-1.id
  security_groups = [aws_security_group.my-security-group.id]

  tags = {
    Name = "my-ec2"
  }
}
