resource "aws_vpc" "app_cluster" {

  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "playlist_pal_${var.environment}_vpc"
    Environment = "${var.environment}"
  }

}

resource "aws_subnet" "app_cluster" {
  vpc_id                  = "${aws_vpc.app_cluster.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.app_cluster.cidr_block, 8, count.index)}"

  map_public_ip_on_launch = true

  availability_zone = "${element(var.aws_availability_zones, count.index)}"
  count = "${length(var.aws_availability_zones)}"
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.app_cluster.id}"

  tags {
    Name = "${var.environment}_internet_gateway"
    Environment = "${var.environment}"
  }

}


resource "aws_route_table_association" "a" {
  count = "${length(var.aws_availability_zones)}"
  subnet_id      = "${element(aws_subnet.app_cluster.*.id, count.index)}"
  route_table_id = "${aws_route_table.app.id}"
}


resource "aws_route_table" "app" {
  vpc_id = "${aws_vpc.app_cluster.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    cluster = "${aws_ecs_cluster.app.name}"
    Name    = "${aws_ecs_cluster.app.name}.ecs"
  }
}

//
//resource "aws_route" "internet_access" {
//  route_table_id         = "${aws_vpc.app_cluster.main_route_table_id}"
//  destination_cidr_block = "0.0.0.0/0"
//  gateway_id             = "${aws_internet_gateway.default.id}"
//}
