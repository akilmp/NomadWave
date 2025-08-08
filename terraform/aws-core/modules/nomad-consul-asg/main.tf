data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-arm64"]
  }
}

resource "aws_iam_role" "this" {
  name = "${var.name}-nomad-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-nomad-profile"
  role = aws_iam_role.this.name
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-nomad-"
  image_id      = data.aws_ami.al2023.id
  instance_type = "t4g.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  vpc_security_group_ids = [var.security_group_id]
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.name}-nomad-asg"
  max_size            = var.desired_capacity
  min_size            = var.desired_capacity
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-nomad"
    propagate_at_launch = true
  }
}

resource "aws_route53_zone" "this" {
  name = var.zone_name
}

data "aws_instances" "nomad" {
  depends_on = [aws_autoscaling_group.this]
  filter {
    name   = "tag:Name"
    values = ["${var.name}-nomad"]
  }
  instance_state_names = ["running"]
}
