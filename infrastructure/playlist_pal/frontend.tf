resource "aws_ecs_task_definition" "frontend" {
  container_definitions = "${data.template_file.frontend.rendered}"
  family = "service"
}

resource "aws_ecs_service" "frontend" {

  name = "frontend"
  cluster = "${aws_ecs_cluster.app.id}"
  task_definition = "${aws_ecs_task_definition.frontend.arn}"
  desired_count = 1
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
  }

}