#  to specify a launch configuration
resource "aws_launch_configuration" "BastionHost" {
  image_id                    = var.image_id
  instance_type               = var.instance_type
  key_name                    = var.ec2_key_pair
  security_groups             = [aws_security_group.SSH-Access-for-Bastion.id]
  associate_public_ip_address = true
}


# the auto scaling group, which references the above launch configuration
resource "aws_autoscaling_group" "BastionHost" {
  name                 = var.aws_autoscaling_group_name
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.BastionHost.name
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = [var.public_subnet_az1_id, var.public_subnet_az2_id]
}

# create security group for the bastion
resource "aws_security_group" "SSH-Access-for-Bastion" {
  name        = var.security_group_name
  description = "enable SSH access on port 22"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}
