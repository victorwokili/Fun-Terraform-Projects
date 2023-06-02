output "public_ip_address" {
  value = aws_instance.my_server.public_ip
}