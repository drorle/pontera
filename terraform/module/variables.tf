variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
  validation {
    condition     = can(regex("^us\\-\\w+\\-\\d+$", var.region))
    error_message = "The region must be a valid AWS region identifier, e.g., us-east-1."
  }
}

variable "app_name" {
  description = "Default name for an application if not specified"
  type        = string
  default     = "default-app"
}

variable "apps" {
  description = "List of applications to deploy"
  type = list(object({
    name             = optional(string, "myApp")
    deploy_type      = optional(string, "EC2")
    subnets          = list(string)
    security_groups  = optional(list(string),[])
    ami              = optional(string, "ami-0cff7528ff583bf9a")
    instance_type    = optional(string, "t3.micro")
    volume_size      = optional(number, 20)
    user_data        = optional(string, "")
    iam_role         = optional(string,"")
    asg = optional(object({
      min     = number
      max     = number
      desired = number
    }),null)
    sg_rules = optional(list(object({
      type        = string
      protocol    = string
      from_port   = number
      to_port     = number
      cidr_blocks = list(string)
      description = string
    })),null)
    alb = optional(object({
      deploy       = bool
      subnets      = list(string)
      sg           = string
      listen_port  = number
      dest_port    = number
      host         = string
      path         = string
    }),null)
  }))
  default = [
    {
      name             = "app0"
      deploy_type      = "EC1"
      subnets          = ["subnet-12346"]
      security_groups  = ["sg-12346"]
      ami              = "ami-1cff7528ff583bf9a"
      instance_type    = "t2.micro"
      volume_size      = 19
      user_data        = "echo Hello World"
      iam_role         = "arn:aws:iam::123456789011:role/ecsInstanceRole"
      asg = {
        min     = 0
        max     = 2
        desired = 1
      }
      sg_rules = [
        {
          type        = "ingress"
          protocol    = "tcp"
          from_port   = 21
          to_port     = 21
          cidr_blocks = ["76.137.74.255/32"]
          description = "Allow HTTP traffic"
        }
      ]
      alb = {
        deploy       = true
        subnets      = ["subnet-12346", "subnet-67890"]
        sg           = "sg-12346"
        listen_port  = 21
        dest_port    = 21
        host         = "example.com"
        path         = "/"
      }
    }
  ]
}
