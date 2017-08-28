resource "aws_ecr_repository" "playlist_pal" {
  name = "playlist_pal_${var.environment}"
}

resource "aws_ecs_cluster" "app" {
  name = "playlist_pal_${var.environment}"
}


resource "aws_instance" "ingest" {

  ami = "ami-8fcc32f6"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.app_cluster.0.id}"
  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.app.name} >> /etc/ecs/ecs.config
EOF
  iam_instance_profile = "${aws_iam_instance_profile.ecs_service.name}"
  security_groups = ["${aws_security_group.ecs.id}"]

}

resource "aws_alb_target_group_attachment" "test" {
  target_group_arn = "${aws_alb_target_group.frontend.arn}"
  target_id        = "${aws_instance.ingest.id}"
  port             = 80
}
