################################################################################
# ECS cluster tasks SG
################################################################################
resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-security-group"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc_id

  # Traffic to the ECS cluster should only come from the ALB SG
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = [var.alb_id]
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

################################################################################
# ECS Cluster definition
################################################################################
resource "aws_ecs_cluster" "main" {
  name = "${var.project}_cluster"
}

################################################################################
# BOOKS API ECS Tasks
################################################################################
data "template_file" "service_template_file" {
  template = "${file("${path.module}/templates/ecs/api.json.tpl")}"
  vars = {
    service_name         = var.service_name
    image                = var.service_image
    container_port       = var.service_port
    host_port            = var.service_port
    fargate_cpu          = var.fargate_cpu
    fargate_memory       = var.fargate_memory
    aws_region           = var.region
    aws_logs_group       = var.service_aws_logs_group
  }
}

resource "aws_ecs_task_definition" "service_td" {
  family                   = var.service_task_family
  execution_role_arn       = var.ecs_task_execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.service_template_file.rendered
}

################################################################################
# Books API Target Group
################################################################################
resource "aws_alb_target_group" "service_tg" {
  name        = "books-api-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.service_health_check_path
    unhealthy_threshold = "2"
  }
}

################################################################################
# Books API Listener
################################################################################
resource "aws_alb_listener_rule" "books_api_listener_rule" {
  listener_arn = var.aws_alb_listener_main_arn
  priority     = 1

  action {
    type             = "forward" # Redirect all traffic from the ALB to the target group
    target_group_arn = aws_alb_target_group.service_tg.arn
  }

  condition {
    path_pattern {
      values = ["/books", "/books/*"]
    }
  }
}

################################################################################
# BOOKS API ECS Service
################################################################################
resource "aws_ecs_service" "books_api" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.service_td.arn
  desired_count   = var.service_desired_count
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.service_tg.id
    container_name   = var.service_name
    container_port   = var.service_port
  }

  depends_on = [
    var.aws_alb_listener_main, 
    var.ecs_task_execution_role
  ]
}
