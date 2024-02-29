provider "aws" {
    region = "ap-northeast-3"
  
}
provider "aws" {
    region = "ap-northeast-2"
    alias = "virginia"
  
}
resource "aws_instance" "firstInstance" {
 ami ="ami-05ff0b3a7128cd6f8"
 instance_type ="t2.micro"  
 tags = {
    Name = "my-ec2"
 }
}

resource "aws_instance" "ec2-virginia" {
 ami ="ami-0f3a440bbcff3d043"
 instance_type ="t2.micro"  
 provider = aws.virginia
 tags = {
    Name = "my-ec2"
 }
}
