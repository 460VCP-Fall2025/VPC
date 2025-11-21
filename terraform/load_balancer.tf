#------------------------------
#Application Load Balancer and Listener
#------------------------------
resource "aws_lb" "nlb" {
  name               = "nlb"
  internal           = true
  load_balancer_type = "network"
  subnets = [
    aws_subnet.private_blue.id, # us-east-1b
    aws_subnet.private_green.id # us-east-1c
  ]
}



resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 8080
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = local.active_tg
  }
}




#------------------------------
#Resources for BLUE environment
#------------------------------
resource "aws_lb_target_group" "blue" {
  name     = "blue-tg"
  port     = 8080
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30

    port                = "traffic-port"
    protocol            = "TCP"  
    unhealthy_threshold = 2
  }

  tags = {
    Name = "Blue-TG"
  }
}


resource "aws_lb_target_group_attachment" "blue_attachment" {
  target_group_arn = aws_lb_target_group.blue.arn
  target_id        = aws_instance.blue.id #getting instance id
  port             = 8080
}


#------------------------------
#Resources for GREEN environment
#------------------------------

resource "aws_lb_target_group" "green" {
  name     = "green-tg"
  port     = 8080
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    # Remove matcher and path - TCP doesn't use these
    port                = "traffic-port"
    protocol            = "TCP" 
    unhealthy_threshold = 2
  }

  tags = {
    Name = "Green-TG"
  }
}


resource "aws_lb_target_group_attachment" "green_attachment" {
  target_group_arn = aws_lb_target_group.green.arn
  target_id        = aws_instance.green.id #getting instance id
  port             = 8080
}



















