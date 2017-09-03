
//
### ECS Postgres containers
data "template_file" "ecs_postgres_def" {
  template = "${file("${path.module}/templates/postgres-def.tpl.json")}"

  vars {
    postgres_user = "${var.postgres_user}"
    postgres_password = "${var.postgres_password}"
    postgres_db = "${var.postgres_db}"
    environment = "${var.environment}"
    cloudwatch_log_group = "${aws_cloudwatch_log_group.playlist_pal.arn}"
    cloudwatch_region    = "${var.aws_region}"
  }

}
//
resource "aws_ecs_task_definition" "postgres" {
  family                = "postgres_${var.environment}"
  container_definitions = "${data.template_file.ecs_postgres_def.rendered}"
}

resource "aws_ecs_service" "postgres" {

  name = "postgres_${var.environment}"
  cluster = "${aws_ecs_cluster.app.id}"
  task_definition = "${aws_ecs_task_definition.postgres.arn}"
  desired_count = 1
  #iam_role = "${aws_iam_role.ecs_service.arn}"

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  depends_on = [
    "aws_iam_role_policy.ecs_service"
  ]

}