resource "aws_lb" "nlb" {
  name               = "nlb-ecs-test"
  internal           = true
  load_balancer_type = "network"
  subnets            = aws_subnet.private_subnet.*.id

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "nlb_tg" {
  depends_on  = [
    aws_lb.nlb
  ]
  name        = "nlb-syn-ecomm-ecs-tg"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
}

# Redirect all traffic from the NLB to the target group
resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.id
  port              = 80
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.nlb_tg.id
    type             = "forward"
  }
}


resource "aws_alb" "application_load_balancer" {
  name               = "ecs-alb-tf" # Naming our load balancer
  load_balancer_type = "application"
  subnets            = aws_subnet.private_subnet.*.id
  security_groups    = ["${aws_security_group.alb_security_group.id}"]
}


resource "aws_lb_target_group" "alb_target_group" {
  name        = "target-group-alb"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${aws_vpc.vpc.id}"
  health_check {
    matcher = "200,301,302"
    path = "/"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${aws_alb.application_load_balancer.arn}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.alb_target_group.arn}"
  }
}