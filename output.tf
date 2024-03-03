output "public-ip-of-instance" {
    description = "The public ip of instance"
    value = aws_instance.example.public_ip
  
}
output "private-ip-of-instance" {
    description = "The private ip of instance"
    value = aws_instance.example.private_ip
  
}
