output "public_dns_name" {
  value = aws_lb.ecs_lb.dns_name 
}
