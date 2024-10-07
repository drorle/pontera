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
    instance_type    = optional(string, "t2.micro")
    volume_size      = optional(number, 20)
    user_data        = optional(string, "")
    iam_role         = optional(string,"")
    asg = optional(object({
      min     = optional(number,1)
      max     = optional(number,3)
      desired = optional(number,2)
    }),{
      min = 1
      max = 3
      desired = 2
    }
    )
    sg_rules = optional(list(object({
      type        = optional(string, "ingress")
      protocol    = optional(string, "tcp")
      from_port   = optional(number,22)
      to_port     = optional(number,22)
      cidr_blocks = optional(list(string),[])
      description = optional(string,"")
    })),[
      {
        type        = "ingress"
        protocol    = "tcp"
        from_port   = 22
        to_port     = 22
        cidr_blocks = []
        description = ""
      }
    ])
    alb = optional(object({
      deploy       = optional(bool,false)
      subnets      = optional(list(string),[])
      sg           = optional(string,null)
      listen_port  = optional(number,22)
      dest_port    = optional(number,22)
      host         = optional(string,"")
      path         = optional(string,"")
    }),
      {
        deploy = false
        subnets = []
        sg = null
        listen_port = 22
        dest_port = 22
        host = ""
        path = ""
      }
    )
  }))
  default = [
    {
      name             = "app0"
      deploy_type      = "EC2"
      subnets          = []
      security_groups  = []
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
