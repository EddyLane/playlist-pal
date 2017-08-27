resource "aws_alb" "frontend" {
  name            = "playlist-pal-${var.environment}-alb"
  subnets         = ["${aws_subnet.app_cluster.*.id}"]
  security_groups = ["${aws_security_group.alb_sg.id}"]

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "aws_alb_target_group" "frontend" {

  name     = "playlist-pal-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.app_cluster.id}"

//  health_check {
//    healthy_threshold   = 2
//    unhealthy_threshold = 3
//    timeout             = 3
//    protocol            = "HTTP"
//    interval            = 5
//    matcher             = "200,404"
//  }
}

resource "aws_security_group" "alb_sg" {
  description = "Controls access to and from the ALB"

  vpc_id = "${aws_vpc.app_cluster.id}"
  name   = "playlist-pal.${var.environment}.alb-sg"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

}

resource "aws_alb_listener" "frontend" {
  load_balancer_arn = "${aws_alb.frontend.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.frontend.id}"
    type             = "forward"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.app_cluster.id}"

  tags {
    Name = "${var.environment}_internet_gateway"
    Environment = "${var.environment}"
  }

}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.app_cluster.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}
