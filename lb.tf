resource "aws_lb_target_group" "ecs_tg" {
  name     = "aa-target-group"
  port     = 4080
  protocol = "HTTP"
  vpc_id   = var.VPC_ID

  #   health_check {
  #     interval            = 30
  #     path                = "/"
  #     timeout             = 5
  #     healthy_threshold   = 1
  #     unhealthy_threshold = 1
  #     matcher             = "200-299"
  #   }

  tags = {
    Name = "ecs-target-group"
  }
}


resource "aws_lb" "ecs_lb" {
  name               = "aa-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.SECURITY_GROUPS
  subnets            = var.SUBNET_IDS

  enable_deletion_protection = false

  tags = {
    Name = "aa-load-balancer"
  }
}


resource "aws_lb_listener" "ecs_lb_listener" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}
