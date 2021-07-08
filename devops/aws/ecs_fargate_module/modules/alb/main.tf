################################################################################
# ALB Definition
################################################################################
resource "aws_alb" "main" {
  name            = var.alb_name
  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.lb.id]
}

resource "aws_alb_target_group" "main" {
  name                 = "${var.alb_name}-${var.environment}"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = var.deregistration_delay

  health_check {
    path                = var.health_check_path
    protocol = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.main.id
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

# ################################################################################
# # ALB Default TG
# ################################################################################
# resource "aws_alb_target_group" "default" {
#   name                 = "${var.alb_name}-default"
#   port                 = 80
#   protocol             = "HTTP"
#   vpc_id               = var.vpc_id
#   deregistration_delay = var.deregistration_delay

#   health_check {
#     path     = var.health_check_path
#     protocol = "HTTP"
#   }
# }

# resource "aws_alb_listener" "main" {
#   load_balancer_arn = aws_alb.main.id
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     target_group_arn = aws_alb_target_group.default.id
#     type             = "forward"
#   }
# }

################################################################################
# ALB SG
################################################################################
resource "aws_security_group" "lb" {
  name        = "load-balancer-security-group"
  description = "controls access to the ALB"
  vpc_id      = var.vpc_id

  # Accept incoming access to port 80 from anywhere
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
