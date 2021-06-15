output "alb_id" {
  value = aws_alb.main.id
}

output "aws_alb_listener_main_arn" {
  value = aws_alb_listener.main.arn
}

output "aws_alb_listener_main" {
  value = aws_alb_listener.main
}

output "aws_security_group_lb_id" {
  value = aws_security_group.lb.id
}
