module "app_deployment" {
  source = "./module"
  
  region = "us-east-1"
  apps   = [
    {
      subnets     = [aws_subnet.my_subnet.id]
      security_groups = []
      sg_rules    = [
        {
          type        = "ingress"
          protocol    = "tcp"
          from_port   = 80
          to_port     = 80
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow HTTP"
        }
      ]
      alb         = {
        deploy      = false
        subnets     = []
        sg          = ""
        listen_port = 0
        dest_port   = 0
        host        = ""
        path        = ""
      }
    },
    # Add more app configurations as needed
  ]
}