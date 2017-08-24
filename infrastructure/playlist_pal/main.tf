resource "aws_ecr_repository" "playlist_pal" {
  name = "playlist_pal"
}

resource "aws_ecs_cluster" "app" {
  name = "playlist_pal"
}

resource "aws_ecs_task_definition" "frontend" {
  container_definitions = "${file("../../playlist_pal/ecs_service.json")}"
  family = "service"
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend"
  cluster         = "${aws_ecs_cluster.app.id}"
  task_definition = "${aws_ecs_task_definition.frontend.arn}"
  desired_count   = 1
}