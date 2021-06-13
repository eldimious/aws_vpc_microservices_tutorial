################################################################################
# ALB Definition
################################################################################
resource "aws_alb" "main" {
  name            = "load-balancer"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

################################################################################
# Books API Target Group
################################################################################
resource "aws_alb_target_group" "books_api" {
  name        = "books-api-tg"
  port        = 80
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

resource "aws_alb_listener" "main" {
  load_balancer_arn = aws_alb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.books_api.id
    type             = "forward"
  }
}

# ################################################################################
# # Users API Target Group
# ################################################################################
# resource "aws_alb_target_group" "users_api" {
#   name        = "users-api-tg"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = aws_vpc.main.id
#   target_type = "ip"

#   health_check {
#     healthy_threshold   = "3"
#     interval            = "30"
#     protocol            = "HTTP"
#     matcher             = "200"
#     timeout             = "3"
#     path                = var.users_api_health_check_path
#     unhealthy_threshold = "2"
#   }
# }

# ################################################################################
# # Users API Listeners
# ################################################################################
# resource "aws_alb_listener_rule" "users_api" {
#   listener_arn = aws_alb_listener.main.arn
#   priority     = 2

#   action {
#     type             = "forward" # Redirect all traffic from the ALB to the target group
#     target_group_arn = aws_alb_target_group.users_api.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/users", "/users/*"]
#     }
#   }
# }

################################################################################
# Books API Listener
################################################################################
resource "aws_alb_listener_rule" "books_api" {
  listener_arn = aws_alb_listener.main.arn
  priority     = 1

  action {
    type             = "forward" # Redirect all traffic from the ALB to the target group
    target_group_arn = aws_alb_target_group.books_api.arn
  }

  condition {
    path_pattern {
      values = ["/books", "/books/*"]
    }
  }
}
