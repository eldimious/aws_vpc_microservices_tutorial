
# Get latest Amazon Linux 2 AMI by Amazon
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_launch_configuration" "ecs_launch_config" {
    name = "ECS ${var.project}"
    image_id = data.aws_ami.amazon-linux-2.image_id
    iam_instance_profile = aws_iam_instance_profile.ecs.arn
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
    associate_public_ip_address = false
}

resource "aws_autoscaling_group" "ecs_ec2_asg" {
  name                 = "ECS EC2 ASG"
  vpc_zone_identifier  = aws_subnet.private.*.id
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
}

resource "aws_iam_instance_profile" "ecs" {
  name = "ecs-ec2-cluster"
  role = aws_iam_role.ecs.name
}

resource "aws_iam_role" "ecs" {
  name               = "ecs-ec2-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_attach" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
# resource "aws_launch_configuration" "ecs_launch_config" {
#   image_id                    = "ami-09a3cad575b7eabaa"
#   iam_instance_profile        = aws_iam_instance_profile.ecs.arn
#   security_groups             = [aws_security_group.ecs_task.id]
#   user_data                   = "#!/bin/bash\necho ECS_CLUSTER=app-cluster >> /etc/ecs/ecs.config"
#   instance_type               = "t2.micro"
#   associate_public_ip_address = true
# }

resource "aws_ecs_cluster" "main" {
  name = "${var.project}-cluster"
  tags = {
    name = "${var.project}-cluster"
  }
}

data "template_file" "books_api" {
  template = file("./templates/ecs/books_api_task_definition.json.tpl")

  vars = {
    service_name         = "books_api"
    image                = "eldimious/books:latest"
    container_port       = var.books_api_port
    host_port            = var.books_api_port
    fargate_cpu          = var.fargate_cpu
    fargate_memory       = var.fargate_memory
    aws_region           = var.aws_region
    aws_logs_group       = "/ecs/books_api"
  }
}

resource "aws_ecs_task_definition" "books_api" {
  container_definitions    = data.template_file.books_api.rendered                                        # task defination json file location
  family                   = "books_api_task"                                                                     # task name
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  requires_compatibilities = ["EC2"]                                                                                       # Fargate or EC2
}

resource "aws_ecs_service" "books_api" {
  name            = "books_api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.books_api.arn
  launch_type     = "EC2"
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_alb_target_group.books_api.id
    container_name   = "books_api"
    container_port   = var.books_api_port      # attaching load_balancer target group to ecs
  }

  depends_on = [aws_alb_listener.main]
}