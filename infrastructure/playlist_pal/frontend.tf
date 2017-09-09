resource "aws_ecs_task_definition" "frontend" {
  container_definitions = "${data.template_file.frontend.rendered}"
  family = "service"
}

resource "aws_ecs_service" "frontend" {

  name = "frontend_${var.environment}"
  cluster = "${aws_ecs_cluster.app.id}"
  task_definition = "${aws_ecs_task_definition.frontend.arn}"
  desired_count = "${length(var.aws_availability_zones)}"
  iam_role = "${aws_iam_role.ecs_service.arn}"

  placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.frontend.id}"
    container_name   = "playlist_pal_frontend_${var.environment}"
    container_port   = "80"
  }

  depends_on = [
    "aws_iam_role_policy.ecs_service",
    "aws_alb_listener.frontend",
  ]

}

### ECS ChitChat App containers
data "template_file" "frontend" {

  template = "${file("${path.module}/templates/frontend-def.tpl.json")}"

  vars {
    frontend_version = "${var.frontend_container_version}"
    api_url = "${var.api_url}"
    environment = "${var.environment}"

    cloudwatch_log_group = "${aws_cloudwatch_log_group.playlist_pal.arn}"
    cloudwatch_region    = "${var.aws_region}"
  }

}


resource "aws_security_group" "ecs" {
  name = "ecs-${var.environment}"
  description = "Allows all traffic"
  vpc_id = "${aws_vpc.app_cluster.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

//  ingress {
//    from_port = 0
//    to_port = 0
//    protocol = "-1"
//    security_groups = ["${aws_security_group.alb_sg.id}"]
//  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}