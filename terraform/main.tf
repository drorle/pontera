module "app_deployment" {
  source = "./module"
  
  region = "us-east-1"
  apps   = [
    {
      deploy_type = "ASG"
      subnets     = [aws_subnet.my_subnet.id]
    },
  ]
}