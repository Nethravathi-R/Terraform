provider "aws" {
    region = "ap-south-1"
  
}
resource "aws_instance" "example" {
    ami = "ami-03bb6d83c60fc5f7c"
    instance_type = "t2.micro"
    key_name = "aws key"
    associate_public_ip_address = true //to see attach public ip to instance
    subnet_id = aws_subnet.my_subnet.id
    vpc_security_group_ids = [ aws_security_group.demo-vpc-sg.id ]
  
}
//Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.10.0.0/16"
}
//Create Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id //resource type.resource name//dynamic variable
  cidr_block = "10.10.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "demo_Subnet1"
  }
}
//Create Internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id 

  tags = {
    Name = "my_igw"
  }
}
//Create route table
resource "aws_route_table" "demo-rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "demo-rt"
  }
}
//Create subnet association
resource "aws_route_table_association" "demo-rt-association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.demo-rt.id
}
//Create security group
resource "aws_security_group" "demo-vpc-sg" {
  name        = "demo-vpc-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "demo-vpc-sg1"
  }
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
