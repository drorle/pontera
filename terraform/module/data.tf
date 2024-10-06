data "aws_subnet" "first" {
  for_each = { for app in var.apps : app.name => app }
  id       = each.value.subnets[0]
}
