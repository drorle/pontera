locals {
  ec2_instances = { for app in var.apps : app.name => app if app.deploy_type == "EC2" }
  asg_instances = { for app in var.apps : app.name => app if app.deploy_type == "ASG" }
}

# EC2 Instances
resource "aws_instance" "this" {
  for_each = local.ec2_instances

  ami           = each.value.ami
  instance_type = each.value.instance_type
  subnet_id     = each.value.subnets[0]
  vpc_security_group_ids = each.value.security_groups

  root_block_device {
    volume_size = each.value.volume_size
  }

  user_data = each.value.user_data
  iam_instance_profile = each.value.iam_role

  tags = {
    Name = each.value.name
  }
}

# Auto Scaling Groups
resource "aws_launch_template" "this" {
  for_each = local.asg_instances

  name_prefix   = "${each.value.name}-lt-"
  image_id      = each.value.ami
  instance_type = each.value.instance_type

  vpc_security_group_ids = each.value.security_groups

  user_data = base64encode(each.value.user_data)

  iam_instance_profile {
    name = each.value.iam_role
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = each.value.volume_size
    }
  }
}

resource "aws_autoscaling_group" "this" {
  for_each = local.asg_instances

  name                = "${each.value.name}-asg"
  vpc_zone_identifier = each.value.subnets
  min_size            = each.value.asg.min
  max_size            = each.value.asg.max
  desired_capacity    = each.value.asg.desired

  launch_template {
    id      = aws_launch_template.this[each.key].id
    version = "$Latest"
  }

  target_group_arns = each.value.alb.deploy ? [aws_lb_target_group.this[each.key].arn] : []

  tag {
    key                 = "Name"
    value               = each.value.name
    propagate_at_launch = true
  }
}

# Application Load Balancers
resource "aws_lb" "this" {
  for_each = { for k, v in local.asg_instances : k => v if v.alb.deploy }

  name               = "${each.value.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [each.value.alb.sg]
  subnets            = each.value.alb.subnets

  tags = {
    Name = "${each.value.name}-alb"
  }
}

resource "aws_lb_listener" "this" {
  for_each = { for k, v in local.asg_instances : k => v if v.alb.deploy }

  load_balancer_arn = aws_lb.this[each.key].arn
  port              = each.value.alb.listen_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }
}

resource "aws_lb_target_group" "this" {
  for_each = { for k, v in local.asg_instances : k => v if v.alb.deploy }

  name     = "${each.value.name}-tg"
  port     = each.value.alb.dest_port
  protocol = "HTTP"
  vpc_id   = data.aws_subnet.first[each.key].vpc_id

  health_check {
    path                = each.value.alb.path
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

resource "aws_lb_listener_rule" "this" {
  for_each = { for k, v in local.asg_instances : k => v if v.alb.deploy }

  listener_arn = aws_lb_listener.this[each.key].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }

  condition {
    host_header {
      values = [each.value.alb.host]
    }
  }

  condition {
    path_pattern {
      values = [each.value.alb.path]
    }
  }
}

# Security Groups
resource "aws_security_group" "this" {
  for_each = { for app in var.apps : app.name => app }

  name_prefix = "${each.value.name}-sg"
  description = "Security group for ${each.value.name}"
  vpc_id      = data.aws_subnet.first[each.key].vpc_id

  dynamic "ingress" {
    for_each = each.value.sg_rules
    content {
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = lookup(ingress.value, "security_groups", null)
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${each.value.name}-sg"
  }
}
