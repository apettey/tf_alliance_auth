output "public_dns_address" {
  value = aws_lb.ecs_lb.dns_name
}
