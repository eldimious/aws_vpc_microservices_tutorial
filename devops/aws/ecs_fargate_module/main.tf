provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  region                  = "us-west-1"
}

module "networking" {
	source          = "./modules/network"
  region = "us-west-2"
  vpc_name = "test_vpc"
  cidr_block  = "192.168.0.0/16"
  availability_zones                          = ["us-west-1a", "us-west-1b"]
  public_subnet_cidrs  = [ "192.168.0.0/19", "192.168.32.0/19"]
  private_subnet_cidrs = [ "192.168.128.0/19", "192.168.160.0/19"]
}

module "alb" {
	source          = "./modules/alb"
  vpc_id = module.networking.id
  public_subnet_ids  = module.networking.public_subnet_ids
}

module "roles" {
	source          = "./modules/roles"
  ecs_task_execution_role_name = "myEcsTaskExecutionRole"
}

data "aws_alb_listener" "http" {
  load_balancer_arn = module.alb.alb.arn
  port              = 80
}

module "ecs" {
	source          = "./modules/ecs"
  cluster_name = "ecs_fargate_ms"
  enviroment = "dev"
  fargate_cpu = "256"
  fargate_memory = "512"
  health_check_grace_period_seconds = 180
  service_name = "books_api"
  service_image = "eldimious/books:latest"
  service_aws_logs_group = "/ecs/books_api"
  service_port = 5000
  service_desired_count = 2
  service_max_count = 4
  service_health_check_path = "/books/"
  service_task_family = "books_api_task"
  load_balancer = true
  health_check = {
    enabled             = true
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/books/"
    unhealthy_threshold = "2"
  }
  alb_path_pattern = ["/books", "/books/*"]
  vpc_id = module.networking.id
  private_subnet_ids = module.networking.private_subnet_ids
  alb_id = module.alb.alb_id
  aws_security_group_lb_id = module.alb.aws_security_group_lb_id
  aws_alb_target_group_main_id = module.alb.aws_alb_target_group_main_id
  aws_alb_listener_http = module.alb.aws_alb_listener_http
  # aws_alb_listener_main = module.alb.aws_alb_listener_main
  aws_alb_listener_main_arn = data.aws_alb_listener.http.arn
  ecs_task_execution_role = module.roles.ecs_task_execution_role
  ecs_task_execution_role_arn = module.roles.ecs_task_execution_role_arn
}
