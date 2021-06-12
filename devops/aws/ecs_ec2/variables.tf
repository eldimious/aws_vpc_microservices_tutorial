################################################################################
# General AWS Configuration
################################################################################
variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-west-2"
}
//variable "docker_repo" {}

################################################################################
# Project metadata
################################################################################
variable "project" {
  description = "Project name"
  default     = "project"
}

variable "resource_tag" {
  description = "Name Tag to precede all resources"
  default     = "ecs-alb-efs"
}

################################################################################
# ECS Configuration
################################################################################
variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "myEcsTaskExecutionRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "512"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "1024"
}

################################################################################
# API Books Service Configuration
################################################################################
variable "books_api_port" {
  description = "Port exposed by the books image"
  default     = 5000
}

variable "books_api_count" {
  description = "Number of books docker containers to run"
  default     = 1
}

variable "books_api_health_check_path" {
  default = "/books/"
}

################################################################################
# API Users Service Configuration
################################################################################
variable "users_api_port" {
  description = "Port exposed by the users image"
  default     = 3000
}

variable "users_api_count" {
  description = "Number of users docker containers to run"
  default     = 1
}

variable "users_api_health_check_path" {
  default = "/users"
}

################################################################################
# ALB Configuration
################################################################################
variable "internal_elb" {
  description = "Make ALB private? (Compute nodes are always private under ALB)"
  default     = false
}
