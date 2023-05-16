# Configure AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create a new VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create a new subnet within the VPC
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
}

# Create a security group allowing inbound traffic on port 80
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch two EC2 instances within the subnet
resource "aws_instance" "my_instance_1" {
  ami           = "ami-12345678"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
}

resource "aws_instance" "my_instance_2" {
  ami           = "ami-12345678"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
}

# Create a load balancer
resource "aws_lb" "my_load_balancer" {
  name               = "my-load-balancer"
  load_balancer_type = "application"
  subnets            = [aws_subnet.my_subnet.id]
}

# Attach instances to the load balancer target group
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path = "/"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "my_attachment_1" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.my_instance_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "my_attachment_2" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.my_instance_2.id
  port             = 80
}
