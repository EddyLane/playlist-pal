resource "aws_vpc" "app_cluster" {

  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "playlist_pal_${var.environment}_vpc"
    Environment = "${var.environment}"
  }

}

# Create a subnet to launch our instances into (AZ 1)
resource "aws_subnet" "app_cluster" {
  vpc_id                  = "${aws_vpc.app_cluster.id}"
  cidr_block              = "10.0.${count.index + 1}.0/24"
  map_public_ip_on_launch = true

  availability_zone = "${element(split(",", var.aws_availability_zones), count.index)}"
  count = "${length(split(",", var.aws_availability_zones))}"

}


resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.app_cluster.id}"

  tags {
    Name = "${var.environment}_internet_gateway"
    Environment = "${var.environment}"
  }

}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.app_cluster.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}
