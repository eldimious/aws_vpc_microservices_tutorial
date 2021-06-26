resource "aws_alb" "main" {
  name               = "main-ecs-lb"
  internal           = false
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.lb.id]
}

resource "aws_alb_listener" "web-listener" {
  load_balancer_arn = aws_alb.main.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Resource not found"
      status_code  = "404"
    }
  }
}

################################################################################
# Books API Target Group
################################################################################
resource "aws_alb_target_group" "books_api_tg" {
  name        = "books-api-tg"
  port        = 80 #dn paizei rolo specifying a port for the target group is mandatory but will always be overwritten by the targets that will be attached to the target group. (https://stackoverflow.com/questions/41772377/mapping-multiple-containers-to-an-application-load-balancer-in-terraform)
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.books_api_health_check_path
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener_rule" "books_api_listener_rule" {
  listener_arn = aws_alb_listener.web-listener.arn
  priority     = 1

  action {
    type             = "forward" # Redirect all traffic from the ALB to the target group
    target_group_arn = aws_alb_target_group.books_api_tg.arn
  }

  condition {
    path_pattern {
      values = ["/books", "/books/*"]
    }
  }
}