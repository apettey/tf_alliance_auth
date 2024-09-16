resource "aws_route53_record" "auth" {
  zone_id         = var.zone_id
  name            = var.alliance_auth_domain
  type            = "CNAME"
  ttl             = "30"
  records         = [aws_lb.ecs_lb.dns_name]
  lifecycle {
    prevent_destroy = false
  }
}
