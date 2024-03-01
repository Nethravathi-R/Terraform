provider "aws" {
    region = "us-east-1"
  
}

data "template_file" "web-userdata" {
        template = "${file("staticfile.sh")}"
}

resource "aws_instance" "ec2-mumbai" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.medium"
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data = "${data.template_file.web-userdata.rendered}"
  tags = {
    Name = "my-sonarqube"
  }
}

resource "aws_security_group" "instance" {

  name = var.security_group_name

        ingress {
                from_port = 80
                to_port = 80
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
       
ingress {
                from_port = 9000
                to_port = 9000
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
ingress {
                from_port = 9001
                to_port = 9001
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
  description = "The name of the security group"
  type        = string
  default     = "terraform-example-instance"
}

output "public_ip" {
  value       = aws_instance.ec2-mumbai.public_ip
  description = "The public IP of the Instance"
}
