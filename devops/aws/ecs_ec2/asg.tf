data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon", "self"]
}

resource "aws_security_group" "ec2-sg" {
  name        = "allow-all-ec2"
  description = "allow all"
  vpc_id      = aws_vpc.main.id
  # Traffic to the ECS cluster should only come from the ALB SG
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    # from_port                = 32768 # ephemeral port range for bridge networking tasks
    # to_port                  = 60999 
    # protocol  = "TCP"
    # Only allowing traffic in from the load balancer security group
    security_groups = [aws_security_group.lb.id]
    # source_security_group_id = module.alb.alb_security_group_id
    # security_group_id        = module.ecs_instances.ecs_instance_security_group_id
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

resource "aws_launch_configuration" "lc" {
  name          = "test_ecs"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  lifecycle {
    create_before_destroy = true
  }
  iam_instance_profile        = aws_iam_instance_profile.ecs_service_role.name
#   key_name                    = "test-key-name"
  security_groups             = [aws_security_group.ec2-sg.id]
  associate_public_ip_address = false
  user_data                   = <<EOF
#! /bin/bash
sudo apt-get update
sudo echo "ECS_CLUSTER=${var.project}" >> /etc/ecs/ecs.config
EOF
}

resource "aws_autoscaling_group" "asg" {
  name                      = "test-asg"
  launch_configuration      = aws_launch_configuration.lc.name
  min_size                  = 1
  max_size                  = 4
  desired_capacity          = 1
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = aws_subnet.private.*.id

  target_group_arns     = [aws_lb_target_group.books_api_tg.arn]
  protect_from_scale_in = true
  lifecycle {
    create_before_destroy = true
  }
}