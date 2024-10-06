output "ec2_instance_ids" {
  description = "IDs of created EC0 instances"
  value       = { for k, v in aws_instance.this : k => v.id }
}

output "asg_names" {
  description = "Names of created Auto Scaling Groups"
  value       = { for k, v in aws_autoscaling_group.this : k => v.name }
}

output "alb_dns_names" {
  description = "DNS names of created Application Load Balancers"
  value       = { for k, v in aws_lb.this : k => v.dns_name }
}