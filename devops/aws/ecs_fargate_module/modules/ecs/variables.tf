# region
variable "region" {
  description = "The region to use for this module."
  default     = "us-west-2"
}

################################################################################
# Project metadata
################################################################################
variable "project" {
  description = "Project name"
  default     = "ecs_fargate_ms"
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "alb_id" {
  description = "The VPC id"
}

variable "aws_alb_listener_main_arn" {
  description = "The VPC id"
}

variable "aws_alb_listener_main" {
  description = "The VPC id"
}

variable "aws_security_group_lb_id" {
  description = "The VPC id"
}

################################################################################
# ECS Configuration
################################################################################
variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "health_check_grace_period_seconds" {
  description = ""
  default     = 180
}

################################################################################
# API Books Service Configuration
################################################################################
variable "service_name" {
  description = "Defines service name"
  default     = "books_api"
}

variable "service_image" {
  description = "Defines service image"
  default     = "eldimious/books:latest"
}

variable "service_aws_logs_group" {
  description = "Defines logs group"
  default     = "/ecs/books_api"
}

variable "service_port" {
  description = "Port exposed by the books image"
  default     = 5000
}

variable "service_desired_count" {
  description = "Number of books docker containers to run"
  default     = 2
}

variable "service_max_count" {
  description = "Max number of books docker containers to run"
  default     = 4
}

variable "service_health_check_path" {
  default = "/books/"
}

variable "service_task_family" {
  description = "Defines logs group"
  default     = "books_api_task"
}

variable "ecs_task_execution_role_arn" {
  description = "Defines logs group"
}

variable "ecs_task_execution_role" {
  description = "Defines logs group"
}

variable "private_subnet_ids" {
  description = "Defines logs group"
}
