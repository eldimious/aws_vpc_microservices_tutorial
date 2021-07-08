variable "public_subnet_ids" {
  type        = list
  description = "List of public ids"
}

variable "alb_name" {
  default     = "default"
  description = "The name of the loadbalancer"
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "deregistration_delay" {
  default     = "300"
  description = "The default deregistration delay"
}

variable "health_check_path" {
  default     = "/"
  description = "The default health check path"
}

variable "environment" {
  description = "Indicate the environment"
  default     = "dev"
}