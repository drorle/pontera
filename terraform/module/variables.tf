variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "apps" {
  description = "List of applications to deploy"
  type = list(object({
    name             = string
    deploy_type      = string
    subnets          = list(string)
    security_groups  = list(string)
    ami              = string
    instance_type    = string
    volume_size      = number
    user_data        = string
    iam_role         = string
    asg = object({
      min     = number
      max     = number
      desired = number
    })
    sg_rules = list(object({
      type        = string
      protocol    = string
      from_port   = number
      to_port     = number
      cidr_blocks = list(string)
      description = string
    }))
    alb = object({
      deploy       = bool
      subnets      = list(string)
      sg           = string
      listen_port  = number
      dest_port    = number
      host         = string
      path         = string
    })
  }))
}
