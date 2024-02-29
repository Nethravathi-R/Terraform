provider "aws" {
    region = "ap-south-1"
  
}
provider "aws" {
 region ="ap-northeast-2"
 alias ="instance2"
}
resource "aws_instance" "ec2-mumbai" {
 ami ="ami-05ff0b3a7128cd6f8"
 instance_type ="t2.micro"  
 tags = {
    Name = "my-ec2"
 }
}

resource "aws_instance" "ec2-instance2" {
 ami ="ami-0c7217cdde317cfec"
 instance_type ="t2.micro"  
 provider = aws.instance2
 tags = {
    Name = "my-ec2"
 }
}
