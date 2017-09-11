resource "aws_launch_configuration" "app" {

  security_groups = [
    "${aws_security_group.ecs.id}",
  ]

  //image_id                    = "ami-13c8f475"          # WeaveNet ECS AMI
  //image_id                    = "ami-8fcc32f6"        # ECS AMI
  image_id = "ami-a8d2d7ce"

  instance_type               = "t2.micro"

  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.ecs_service.name}"
//  user_data = <<EOF
//#!/bin/bash
//echo ECS_CLUSTER=${aws_ecs_cluster.app.name} >> /etc/ecs/ecs.config
//EOF
  user_data = "${data.template_file.user_data.rendered}"
  key_name = "playlist_pal"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    "aws_ecs_cluster.app"
  ]
}



data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user-data.tpl.sh")}"

  vars {
    aws_region        = "${var.aws_region}"
    ecs_cluster_name  = "${aws_ecs_cluster.app.name}"
    ecs_log_level     = "info"
    ecs_agent_version = "latest"
    mount_volume = "false"
  }
}


resource "aws_autoscaling_group" "app_cluster" {
  name                 = "playlist-pal-${var.environment}-asg"
  vpc_zone_identifier  = ["${aws_subnet.app_cluster.*.id}"]
  min_size             = "1"
  desired_capacity     = "2"
  max_size             = "5"
  launch_configuration = "${aws_launch_configuration.app.name}"
  target_group_arns = [
    "${aws_alb_target_group.frontend.arn}",
    "${aws_alb_target_group.backend.arn}"
  ]
}
