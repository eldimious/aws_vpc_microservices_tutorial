resource "aws_ecs_cluster" "main" {
  name = "${var.project}-cluster"
}

data "template_file" "books_api" {
  template = file("./templates/ecs/books_api_task_definition.json.tpl")
  vars = {
    books_api_image     = "eldimious/books:latest"
    container_port      = var.books_api_port
    fargate_cpu         = var.fargate_cpu
    fargate_memory      = var.fargate_memory
    aws_region          = var.aws_region
    aws_logs_group      = "/ecs/books_api",
    alb                 = "${aws_alb.main.dns_name}"
  }
  # count = "${length(split(",", var.container_name))}"
}

resource "aws_ecs_task_definition" "books_api" {
  family                   = "books_api_task"
  container_definitions    = data.template_file.books_api.rendered
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.application.arn
  volume {
    name      = "efs"
    host_path = "/ecs/books_api"
  }
  # count         = "${length(split(",", var.container_name))}"
}

resource "aws_ecs_service" "books_api" {
  name                               = "books_api"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.books_api.arn
  desired_count                      = var.books_api_count
  deployment_minimum_healthy_percent = 50
  iam_role                           = aws_iam_role.application.name

  load_balancer {
    target_group_arn = aws_alb_target_group.books_api.id
    container_name   = "books_api"
    container_port   = var.books_api_port
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }

  depends_on = [
    aws_alb_listener.main,
    aws_iam_role_policy.application,
    aws_iam_role_policy.ec2,
    aws_iam_role_policy_attachment.ecs_task_execution_role
  ]

  # depends_on = [
  #   "aws_iam_role_policy.application",
  #   "aws_iam_role_policy.ec2",
  #   "aws_alb_listener.front_end",
  # ]
}

################################################################################
# USERS API ECS Tasks
################################################################################

data "template_file" "users_api" {
  template = file("./templates/ecs/users_api_task_definition.json.tpl")

  vars = {
    users_api_image     = "eldimious/users:latest"
    container_port      = var.users_api_port
    fargate_cpu         = var.fargate_cpu
    fargate_memory      = var.fargate_memory
    aws_region          = var.aws_region
    aws_logs_group      = "/ecs/users_api",
    alb                 = "${aws_alb.main.dns_name}"
  }
}

resource "aws_ecs_task_definition" "users_api" {
  family                   = "users_api_task"
  container_definitions    = data.template_file.users_api.rendered
  volume {
    name      = "efs"
    host_path = "/ecs/users_api"
  }
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.application.arn
  # count         = "${length(split(",", var.container_name))}"
}

resource "aws_ecs_service" "users_api" {
  name                               = "users_api"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.books_api.arn
  desired_count                      = var.users_api_count
  deployment_minimum_healthy_percent = 50
  iam_role                           = aws_iam_role.application.name

  load_balancer {
    target_group_arn = aws_alb_target_group.books_api.id
    container_name   = "books_api"
    container_port   = var.books_api_port
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }

  depends_on = [
    aws_alb_listener.main,
    aws_iam_role_policy.application,
    aws_iam_role_policy.ec2,
    aws_iam_role_policy_attachment.ecs_task_execution_role,
  ]
}