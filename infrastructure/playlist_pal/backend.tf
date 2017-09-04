resource "aws_ecs_task_definition" "backend" {
  container_definitions = "${data.template_file.backend.rendered}"
  family = "service"
}

resource "aws_ecs_service" "backend" {

  name = "backend_${var.environment}"
  cluster = "${aws_ecs_cluster.app.id}"
  task_definition = "${aws_ecs_task_definition.backend.arn}"
  desired_count = 1
  iam_role = "${aws_iam_role.ecs_service.arn}"

  placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.backend.id}"
    container_name   = "playlist_pal_backend_${var.environment}"
    container_port   = "4000"
  }

  depends_on = [
    "aws_iam_role_policy.ecs_service",
    "aws_alb_listener.backend",
  ]

}

### ECS ChitChat App containers
data "template_file" "backend" {

  template = "${file("${path.module}/templates/backend-def.tpl.json")}"

  vars {
    backend_version = "${var.backend_container_version}"
    api_url = "${var.api_url}"
    environment = "${var.environment}"
    postgres_host = "${aws_db_instance.postgres.address}"
    postgres_user = "${var.postgres_user}"
    postgres_db = "${var.postgres_db}"
    postgres_password = "${var.postgres_password}"
    postgres_port = "${var.postgres_port}"
    guardian_secret_key = "${var.guardian_secret_key}"
    secret_key_base = "${var.secret_key_base}"
    domain = "${var.domain}"
    cloudwatch_log_group = "${aws_cloudwatch_log_group.playlist_pal.arn}"
    cloudwatch_region    = "${var.aws_region}"
  }

}