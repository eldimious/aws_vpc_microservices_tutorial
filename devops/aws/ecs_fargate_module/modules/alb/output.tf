output "alb_id" {
  value = aws_alb.main.id
}

output "alb" {
  value = aws_alb.main
}

output "aws_alb_target_group_main_id" {
  value = aws_alb_target_group.main.id
}

output "aws_alb_listener_http" {
  value = aws_alb_listener.http
}

# output "aws_alb_listener_main_arn" {
#   value = aws_alb_listener.main.arn
# }

# output "aws_alb_listener_main" {
#   value = aws_alb_listener.main
# }

output "aws_security_group_lb_id" {
  value = aws_security_group.lb.id
}
