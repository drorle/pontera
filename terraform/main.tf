module "app_deployment" {
  source = "./module"
  
  region = "us-east-1"
  apps   = [
    {
      name        = "example-app"
      deploy_type = "EC2"
      subnets     = [aws_subnet.my_subnet.id]
      security_groups = []
      ami         = "ami-1"
      instance_type = "t3.micro"
      volume_size = 20
      user_data   = <<-EOF
                    #!/bin/bash
                    echo "Hello, World!" > index.html
                    nohup python -m SimpleHTTPServer 80 &
                    EOF
      iam_role    = "example-role"
      asg         = null
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