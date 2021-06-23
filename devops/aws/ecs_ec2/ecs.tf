resource "aws_ecs_cluster" "web-cluster" {
  name               = var.project
  capacity_providers = [aws_ecs_capacity_provider.test.name]
}

resource "aws_ecs_capacity_provider" "test" {
  name = "capacity-provider-test"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 85
    }
  }
}

# update file container-def, so it's pulling image from ecr
resource "aws_ecs_task_definition" "task-definition-test" {
  family                = "web-family"
  container_definitions = file("templates/ec2/container-def.json")
  network_mode          = "bridge"
}

resource "aws_ecs_service" "service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.web-cluster.id
  task_definition = aws_ecs_task_definition.task-definition-test.arn
  desired_count   = 1
  launch_type = "EC2"
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  # network_configuration {
  #   security_groups  = [aws_security_group.ec2-sg.id]
  #   subnets          = aws_subnet.private.*.id
  #   assign_public_ip = false
  # }

  load_balancer {
    target_group_arn = aws_lb_target_group.books_api_tg.arn
    container_name   = "pink-slon"
    container_port   = 5000
  }

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.lb_target_group.arn
  #   container_name   = "pink-slon"
  #   container_port   = 5000
  # }
  # Optional: Allow external changes without Terraform plan difference(for example ASG)
  lifecycle {
    ignore_changes = [desired_count]
  }
  depends_on  = [aws_lb_listener.web-listener]
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/frontend-container"
  tags = {
    "env"       = "dev"
    "createdBy" = "mkerimova"
  }
}