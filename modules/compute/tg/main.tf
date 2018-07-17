############################
# Target Groups
############################
resource "aws_lb_target_group" "target_group" {
  name                  = "tg-${var.project_name}-${var.environment}"
  port                  = 80
  protocol              = "HTTP"
  vpc_id                = "${var.vpc_id}"
  deregistration_delay  = 60

  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}
