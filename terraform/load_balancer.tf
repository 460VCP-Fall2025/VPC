
#------------------------------
#Application Load Balancer and Listener
#------------------------------
resource "aws_lb" "app" {
  name               = "app-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets = [
    aws_subnet.private_a.id, # us-east-1b
    aws_subnet.private_b.id  # us-east-1c
  ]
}



resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
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
  name        = "blue-tg"
  port        = 8080
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "blue_attachment" {
  target_group_arn = aws_lb_target_group.blue.arn
  target_id        = aws_instance.blue.private_ip
  port             = 8080
}


#------------------------------
#Resources for GREEN environment
#------------------------------
resource "aws_lb_target_group" "green" {
  name        = "green-tg"
  port        = 8080
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "green_attachment" {
  target_group_arn = aws_lb_target_group.green.arn
  target_id        = aws_instance.green.private_ip
  port             = 8080
}








