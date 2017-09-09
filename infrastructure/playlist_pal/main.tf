resource "aws_ecr_repository" "playlist_pal" {
  name = "playlist_pal_${var.environment}"
}

resource "aws_ecs_cluster" "app" {
  name = "playlist_pal_${var.environment}"
}