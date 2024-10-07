module "app_deployment" {
  source = "./module"
  
  region = "us-east-1"
  apps   = [
    {
      subnets     = [aws_subnet.my_subnet.id]
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