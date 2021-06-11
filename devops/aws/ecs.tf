################################################################################
# ECS Cluster definition
################################################################################
resource "aws_ecs_cluster" "main" {
  name = "${var.project}-cluster"
}

resource "aws_service_discovery_private_dns_namespace" "segment" {
  name        = "discovery.local"
  description = "Service discovery for backends"
  vpc         = aws_vpc.main.id
}

resource "aws_service_discovery_service" "books-api-service" {
  name = "books-api-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.segment.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
}

resource "aws_service_discovery_service" "users-api-service" {
  name = "users-api-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.segment.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}


################################################################################
# BOOKS API ECS Tasks
################################################################################
data "template_file" "books_api" {
  template = file("./templates/ecs/books_api.json.tpl")

  vars = {
    books_api_image      = "eldimious/books:latest"
    books_api_port       = var.books_api_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}

resource "aws_ecs_task_definition" "books_api" {
  family                   = "books-api-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.books_api.rendered
}

################################################################################
# BOOKS API ECS Service
################################################################################

resource "aws_ecs_service" "books-api" {
  name            = "books-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.books_api.arn
  desired_count   = var.books_api_count
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 180

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.books_api.id
    container_name   = "books_api"
    container_port   = var.books_api_port
  }

  service_registries {
    registry_arn = aws_service_discovery_service.books-api-service.arn
  }

  depends_on = [aws_alb_listener.main, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

################################################################################
# USERS API ECS Tasks
################################################################################
data "template_file" "users_api" {
  template = file("./templates/ecs/users_api.json.tpl")

  vars = {
    users_api_image       = "eldimious/users:latest"
    users_api_port        = var.users_api_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}

resource "aws_ecs_task_definition" "users_api" {
  family                   = "users-api-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.users_api.rendered
}

################################################################################
# USERS API ECS Service
################################################################################

resource "aws_ecs_service" "users_api" {
  name            = "users-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.users_api.arn
  desired_count   = var.users_api_count
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 180

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.users_api.id
    container_name   = "users_api"
    container_port   = var.users_api_port
  }

  service_registries {
    registry_arn = aws_service_discovery_service.users-api-service.arn
  }

  depends_on = [aws_alb_listener.main, aws_iam_role_policy_attachment.ecs_task_execution_role]
}