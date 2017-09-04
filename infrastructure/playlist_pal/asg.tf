
//resource "aws_instance" "ingest" {
//  ami = "ami-13c8f475"
//  instance_type = "t2.micro"
//  subnet_id = "${aws_subnet.app_cluster.0.id}"
//  user_data = <<EOF
//#!/bin/bash
//echo ECS_CLUSTER=${aws_ecs_cluster.app.name} >> /etc/ecs/ecs.config
//EOF
//  iam_instance_profile = "${aws_iam_instance_profile.ecs_service.name}"
//  security_groups = ["${aws_security_group.ecs.id}"]
//
//}

resource "aws_launch_configuration" "app" {

  security_groups = [
    "${aws_security_group.ecs.id}",
  ]

  image_id                    = "ami-13c8f475"
  instance_type               = "t2.micro"

  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.ecs_service.name}"
  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.app.name} >> /etc/ecs/ecs.config
EOF

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    "aws_ecs_cluster.app",
  ]
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

//  tag {
//    key                 = "Name"
//    value               = "${var.cluster_name}.ecs"
//    propagate_at_launch = true
//  }
//
//  tag {
//    key                 = "cluster"
//    value               = "${var.cluster_name}"
//    propagate_at_launch = true
//  }
}
