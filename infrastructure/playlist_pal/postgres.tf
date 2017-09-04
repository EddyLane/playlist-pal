
//
### ECS Postgres containers
//data "template_file" "ecs_postgres_def" {
//  template = "${file("${path.module}/templates/postgres-def.tpl.json")}"
//
//  vars {
//    postgres_user = "${var.postgres_user}"
//    postgres_password = "${var.postgres_password}"
//    postgres_db = "${var.postgres_db}"
//    environment = "${var.environment}"
//    cloudwatch_log_group = "${aws_cloudwatch_log_group.playlist_pal.arn}"
//    cloudwatch_region    = "${var.aws_region}"
//  }
//
//}
////
//resource "aws_ecs_task_definition" "postgres" {
//  family                = "postgres_${var.environment}"
//  container_definitions = "${data.template_file.ecs_postgres_def.rendered}"
//}
//
//resource "aws_ecs_service" "postgres" {
//
//  name = "postgres_${var.environment}"
//  cluster = "${aws_ecs_cluster.app.id}"
//  task_definition = "${aws_ecs_task_definition.postgres.arn}"
//  desired_count = 1
//  #iam_role = "${aws_iam_role.ecs_service.arn}"
//
//  placement_strategy {
//    type  = "binpack"
//    field = "cpu"
//  }
//
//  depends_on = [
//    "aws_iam_role_policy.ecs_service"
//  ]
//
//}

resource "aws_db_instance" "postgres" {

  identifier           = "${var.environment}"

  engine               = "postgres"
  engine_version       = "9.5.4"

  instance_class       = "${var.rds_size}"
  multi_az             = false
  username             = "${var.postgres_user}"
  password             = "${var.postgres_password}"
  name                 = "${var.postgres_db}"

  vpc_security_group_ids = ["${aws_security_group.db.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.db.id}"

  allocated_storage = 8
  storage_type = "gp2"

  maintenance_window = "Sun:00:10-Sun:03:00"
  backup_window = "23:00-00:00"
  backup_retention_period = "${var.rds_backup_retention_period}"
  port = 5432
  publicly_accessible = true
  apply_immediately = true
  skip_final_snapshot = true

  storage_encrypted = "${var.rds_encryption}"

  depends_on = ["aws_internet_gateway.default"]

}

resource "aws_db_subnet_group" "db" {
  name = "${var.environment}-rds-subnet"
  description = "RDS subnet"
  subnet_ids = ["${aws_subnet.app_cluster.*.id}"]
  tags {
    Name = "${var.environment}_rds_subnet"
  }
}



resource "aws_security_group" "db" {

  name        = "${var.environment}-db-sg"
  description = "Used for RDS"
  vpc_id      = "${aws_vpc.app_cluster.id}"

  # Postgres access from the VPC
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }


}