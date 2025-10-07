############################################
# Networking & Security Groups
############################################

# Fetch default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch default Subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group for Application Load Balancer
resource "aws_security_group" "alb_sg" {
  name        = var.alb_sg_name
  description = "Allow inbound HTTP (80) from anywhere"
  vpc_id      = data.aws_vpc.default.id

  # Inbound rule HTTP from anywhere
  dynamic "ingress" {
    for_each = var.alb_ingress_rules
    content {
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
    }
  }

  # Outbound rule allow all
  dynamic "egress" {
    for_each = var.alb_egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
    }
  }
}

# Security Group for ECS Task
resource "aws_security_group" "task_sg" {
  name        = var.task_sg_name
  description = "Allow inbound 8000 only from ALB SG"
  vpc_id      = data.aws_vpc.default.id

  # Inbound only from ALB SG
  dynamic "ingress" {
    for_each = var.task_ingress_rules
    content {
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      security_groups = [aws_security_group.alb_sg.id]
    }
  }

  # Outbound allow all
  dynamic "egress" {
    for_each = var.task_egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
    }
  }
}