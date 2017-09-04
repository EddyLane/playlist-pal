resource "aws_alb" "app" {
  name            = "playlist-pal-${var.environment}-alb"
  subnets         = ["${aws_subnet.app_cluster.*.id}"]
  security_groups = ["${aws_security_group.alb_sg.id}"]

  provisioner "local-exec" {
    command = "sleep 10"
  }
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

  ingress {
    protocol    = "tcp"
    from_port   = 4000
    to_port     = 4000
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

## FRONTEND

resource "aws_alb_listener" "frontend" {
  load_balancer_arn = "${aws_alb.app.id}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.frontend.id}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "frontend" {
  name     = "playlist-pal-frontend-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.app_cluster.id}"
}

## BACKEND

resource "aws_alb_listener" "backend" {
  load_balancer_arn = "${aws_alb.app.id}"
  port              = 4000
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.backend.id}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "backend" {
  name     = "playlist-pal-backend-${var.environment}-tg"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.app_cluster.id}"
}