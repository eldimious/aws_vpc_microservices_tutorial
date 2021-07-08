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
    security_groups = [var.aws_security_group_lb_id]
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
  name = "${var.cluster_name}_${var.enviroment}"
}

################################################################################
# SERVICE ECS Tasks
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
# SERVICE Target Group
################################################################################
# resource "aws_alb_target_group" "service_tg" {
#   name        = "books-api-tg"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = var.vpc_id
#   target_type = "ip"

#   health_check {
#     healthy_threshold   = "3"
#     interval            = "30"
#     protocol            = "HTTP"
#     matcher             = "200"
#     timeout             = "3"
#     path                = var.service_health_check_path
#     unhealthy_threshold = "2"
#   }
# }

# resource "aws_alb_target_group" "app" {
#   count = var.load_balancer == true ? 1 : 0
#   name        = "service-alb-tg"
#   port        = var.alb_target_group_port
#   protocol    = "HTTP"
#   vpc_id      = var.vpc_id
#   target_type = var.alb_target_group_type

#   dynamic "health_check" {
#     for_each = var.health_check != null ? [1] : []

#     content {
#       enabled             = var.health_check.enabled
#       healthy_threshold   = var.health_check.healthy_threshold
#       interval            = var.health_check.interval
#       matcher             = var.health_check.matcher
#       path                = var.health_check.path
#       protocol            = var.health_check.protocol
#       timeout             = var.health_check.timeout
#       unhealthy_threshold = var.health_check.unhealthy_threshold
#     }
#   }
# }

################################################################################
# SERVICE Listener
################################################################################
# resource "aws_alb_listener_rule" "books_api_listener_rule" {
#   listener_arn = var.aws_alb_listener_main_arn
#   priority     = 1

#   action {
#     type             = "forward" # Redirect all traffic from the ALB to the target group
#     target_group_arn = aws_alb_target_group.service_tg.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/books", "/books/*"]
#     }
#   }
# }

# resource "aws_alb_listener_rule" "forward" {

#   listener_arn = var.aws_alb_listener_main_arn
#   priority     = var.alb_priority

#   action {
#     type             = "forward"
#     target_group_arn = aws_alb_target_group.app.0.arn
#   }

#   dynamic "condition" {
#     for_each = var.alb_path_pattern != null ? [1] : []

#     content {
#       path_pattern {
#         values = var.alb_path_pattern
#       }
#     }
#   }
# }

################################################################################
# SERVICE ECS Service
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
    target_group_arn = var.aws_alb_target_group_main_id
    container_name   = var.service_name
    container_port   = var.service_port
  }

  # dynamic "load_balancer" {
  #   for_each = var.load_balancer == true ? [1] : []
  #   content {
  #     target_group_arn = aws_alb_target_group.app.0.id
  #     container_name   = var.service_name
  #     container_port   = var.service_port
  #   }
  # }

  depends_on = [
    var.aws_alb_listener_http
  ]

  # depends_on = [
  #   var.aws_alb_listener_main, 
  #   var.ecs_task_execution_role
  # ]
}
