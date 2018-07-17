variable "project_name" {
  type          = "string"
  description   = "A logical name that will be used as prefix and tag for the created resources."
}

variable "environment" {
  type        = "string"
  description = "A logical name that will be used as prefix and tag for the created resources."
}

variable "number_of_tasks" {
  type        = "string"
  description = "The number of instances of the task definition to place and keep running."
}

variable "alb_target_group" {
  type        = "string"
  description = "The ARN of the Load Balancer target group to associate with the service."
}

variable "image_tag" {
  type        = "string"
  description = "Tag of the desired Docker Image to deploy."
}
