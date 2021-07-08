# region
variable "region" {
  description = "The region to use for this module."
  default     = "us-west-2"
}

################################################################################
# Project metadata
################################################################################
variable "cluster_name" {
  description = "Project name"
}

variable "enviroment" {
  description = "Project name"
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

# variable "aws_alb_listener_main" {
#   description = "The VPC id"
# }

variable "aws_alb_listener_http" {

}

variable "aws_alb_target_group_main_id" {

}

variable "aws_security_group_lb_id" {
  description = "The VPC id"
}

variable "load_balancer" {
  type        = bool
  description = "Boolean designating a load balancer."
}

variable "alb_target_group_type" {
  type        = string
  default     = "ip"
  description = "The type of target that you must specify when registering targets with this target group."
}

variable "alb_target_group_port" {
  type        = number
  default     = 80
  description = "The port on which targets receive traffic, unless overridden when registering a specific target."
}

variable "alb_priority" {
  default = "1"
}

variable "alb_path_pattern" {
    description = "The port on which targets receive traffic, unless overridden when registering a specific target."
}

variable "health_check" {
  type        = map(any)
  default     = null
  description = "Health check in Load Balance target group."
}


################################################################################
# ECS Configuration
################################################################################
variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
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
}

variable "service_image" {
  description = "Defines service image"
}

variable "service_aws_logs_group" {
  description = "Defines logs group"
}

variable "service_port" {
  description = "Port exposed by the books image"
}

variable "service_desired_count" {
  description = "Number of books docker containers to run"
}

variable "service_max_count" {
  description = "Max number of books docker containers to run"
}

variable "service_health_check_path" {
  description = "Max number of books docker containers to run"
}

variable "service_task_family" {
  description = "Defines logs group"
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
