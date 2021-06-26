resource "aws_ecs_cluster" "main" {
  name               = var.project
  # capacity_providers = [aws_ecs_capacity_provider.capacity_provider.name]
}

# resource "aws_ecs_capacity_provider" "capacity_provider" {
#   name = "capacity-provider-test"
#   auto_scaling_group_provider {
#     auto_scaling_group_arn         = aws_autoscaling_group.books_api_asg.arn
#     managed_termination_protection = "ENABLED"

#     managed_scaling {
#       status          = "ENABLED"
#       target_capacity = 85
#     }
#   }
# }

################################################################################
# BOOKS API ECS Tasks
################################################################################
data "template_file" "books_api" {
  template = file("./templates/ec2/api.json.tpl")
  vars = {
    service_name         = var.books_api_name
    image                = var.books_api_image
    container_port       = var.books_api_port
    host_port            = var.books_api_port
    fargate_cpu          = var.fargate_cpu
    fargate_memory       = var.fargate_memory
    aws_region           = var.aws_region
    aws_logs_group       = var.books_api_aws_logs_group
  }
}

resource "aws_ecs_task_definition" "books_api" {
  family                   = var.books_api_task_family
  container_definitions    = data.template_file.books_api.rendered
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
}

resource "aws_ecs_service" "service" {
  name            = var.books_api_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.books_api.arn
  desired_count   = var.books_api_desired_count
  launch_type     = "EC2"
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.books_api_tg.arn
    container_name   = var.books_api_name
    container_port   = var.books_api_port
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
  depends_on  = [aws_alb_listener.http_listener]
}

################################################################################
# USERS API ECS Tasks
################################################################################
data "template_file" "users_api" {
  template = file("./templates/ec2/api.json.tpl")

  vars = {
    service_name          = var.users_api_name
    image                 = var.users_api_image
    container_port        = var.users_api_port
    host_port             = var.users_api_port
    fargate_cpu           = var.fargate_cpu
    fargate_memory        = var.fargate_memory
    aws_region            = var.aws_region
    aws_logs_group        = var.users_api_aws_logs_group
  }
}

resource "aws_ecs_task_definition" "users_api" {
  family                   = var.users_api_task_family
  container_definitions    = data.template_file.users_api.rendered
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
}

################################################################################
# USERS API ECS Service
################################################################################
resource "aws_ecs_service" "users_api" {
  name            = var.users_api_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.users_api.arn
  desired_count   = var.users_api_desired_count
  launch_type     = "EC2"
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.users_api_tg.arn
    container_name   = var.users_api_name
    container_port   = var.users_api_port
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
  depends_on  = [aws_alb_listener.http_listener]
}
