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

# module "networking" {
# 		    source          = "cn-terraform/networking/aws"
#         version         = "2.0.12"
#         name_prefix    = "base"
#         vpc_cidr_block  = "192.168.0.0/16"
#         availability_zones                          = ["us-west-1a", "us-west-1b"]
#         public_subnets_cidrs_per_availability_zone  = [ "192.168.0.0/19", "192.168.32.0/19"]
#         private_subnets_cidrs_per_availability_zone = [ "192.168.128.0/19", "192.168.160.0/19"]
# 	  }



# module "load_balancer" {
#   source  = "cn-terraform/ecs-alb/aws"
#   version = "1.0.9"
#   vpc_id          = module.networking.vpc_id
#   name_prefix = "public-load-balancer"
#   internal = false
#   public_subnets  = module.networking.public_subnets_ids
#   private_subnets = []
# }

# data "template_file" "books_api" {
#   template = file("./templates/ecs/api.json.tpl")
#   vars = {
#     service_name         = "books_api"
#     image                = "eldimious/books:latest"
#     container_port       = 5000
#     host_port            = 5000
#     fargate_cpu          = 256
#     fargate_memory       = 512
#     aws_region           = "us-west-1"
#     aws_logs_group       = "/ecs/books_api"
#   }
# }

# module "ecs-cluster" {
#   source  = "cn-terraform/ecs-cluster/aws"
#   version = "1.0.7"
#   name = "test"
# }

# # module "books_api_td" {
# #     source  = "cn-terraform/ecs-fargate-task-definition/aws"
# #     version = "1.0.23"
# #     name_prefix = "books-api"
# #     container_name               = "books_api"
# #       container_image              = "eldimious/books:latest"
# #       container_cpu                = 256
# #       container_memory             = 512
# #       container_memory_reservation = 512
# # }


# module "ecs-fargate" {
#       source              = cn-terraform/ecs-fargate/aws
#       version             = 2.0.9
#       name_preffix        = "books_api"
#       region              = "us-west-1"
#       vpc_id              = module.networking.vpc_id
#       availability_zones  = module.networking.availability_zones
#       public_subnets_ids  = []
#       private_subnets_ids = module.networking.private_subnets_ids
#       container_name               = "books_api"
#       container_image              = "eldimious/books:latest"
#       container_cpu                = 256
#       container_memory             = 512
#       essential                    = true
#       container_port               = 5000
#       container_definitions    = data.template_file.books_api.rendered
#         port_mappings = [
#             {
#             containerPort = 5000
#             hostPort      = 5000
#             protocol      = "tcp"
#             }
#         ]
#         desired_count = 1
#         lb_internal = false
#         lb_target_group_health_check_path = "/books"
#   }