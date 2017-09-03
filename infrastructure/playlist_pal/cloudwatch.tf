
resource "aws_cloudwatch_log_group" "playlist_pal" {
  name = "${var.environment}.playlist-pal-container-logs"

  retention_in_days = 7

  tags {
    Name        = "Playlist Pal"
    Environment = "${var.environment}"
  }
}