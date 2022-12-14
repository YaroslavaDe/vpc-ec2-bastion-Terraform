# create application load balancer
resource "aws_lb" "application_load_balancer" {
  name                       = "${var.project_name}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.alb_security_group_id]
  subnets                    = [var.public_subnet_az1_id, var.public_subnet_az2_id]
  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# create target group
resource "aws_lb_target_group" "alb_target_group" {
  name        = "${var.project_name}-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/index.html"
    timeout             = 5
    matcher             = 200
    healthy_threshold   = 10
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

# create a listener on port 80 with redirect action
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
  }

  # Attach the target group
 resource "aws_lb_target_group_attachment" "tg_attachment" {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    target_id        = var.instance_alb
    port             = 80
 }

 # Attach the target group
 resource "aws_lb_target_group_attachment" "tg_attachment_second" {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    target_id        = var.instance_alb_second
    port             = 80
 }