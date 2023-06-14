
# Create a Load Balancer ------------------------------------------------------
resource "aws_lb" "load_balancer" {
  name               = var.ec2_load_balancer_name
  internal           = false
  load_balancer_type = var.ec2_load_balancer_type
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = [aws_subnet.terraform_sub1.id, aws_subnet.terraform_sub2.id]

  enable_deletion_protection = false
  tags = {
    name = "load-balancer"
  }
}

# Create a Load Balancer Target Group -----------------------------------------

resource "aws_lb_target_group" "alb-target" {
  name     = "alb-targets"
  port     = 80
  protocol = var.ec2_load_balancer_traffic_type
  vpc_id   = aws_vpc.my_vpc.id
}

# Create a Load Balancer Listener ---------------------------------------------
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = var.ec2_load_balancer_traffic_type
  tags = {
    name = "listener"
  }
  default_action {
    type             = var.listener_type
    target_group_arn = aws_lb_target_group.alb-target.arn
  }
}
