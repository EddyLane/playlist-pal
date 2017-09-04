resource "aws_ecr_repository" "playlist_pal" {
  name = "playlist_pal_${var.environment}"
}

resource "aws_ecs_cluster" "app" {
  name = "playlist_pal_${var.environment}"
}


//


//resource "aws_alb_target_group_attachment" "test" {
//  target_group_arn = "${aws_alb_target_group.frontend.arn}"
//  target_id        = "${aws_instance.ingest.id}"
//  port             = 80
//}
