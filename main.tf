provider "aws" {
 region ="ap-northeast-3"
}

data "template_file" "web-userdata" {
  template = "${file("sonarqube.sh")}"
}

resource "aws_instance" "firstInstance" {
  ami           = "ami-05ff0b3a7128cd6f8"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data = "${data.template_file.web-userdata.rendered}"
  key_name= "user"
  tags = {
  Name = "my-sonar"
  }
}

resource "aws_security_group" "instance"{
 name = var.aws_security_group

 ingress{
    form_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
 }
 ingress{
    from_port = 8082
    to_port = 8082
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }

 ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
     from_port = 443
     to_port = 443
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
     from_port = 0
     to_port = 0
     protocol = "-1"
     cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "security_group_name" {
  description = "The  name of  the security group"
  type        = string
  default     = "terraform-exmaple-instance"
}

output "instance_public_ip" {
  value = aws.instance.firstInstance.public_ip
  description = "The public ip of Instance"

}
