data "aws_route53_zone" "organisation" {
  name = "eddylane.co.uk."
}

resource "aws_route53_record" "domain" {
  zone_id = "${data.aws_route53_zone.organisation.zone_id}"
  name    = "${var.domain}"
  type    = "A"

  alias {
    name                   = "${aws_alb.frontend.dns_name}"
    zone_id                = "${aws_alb.frontend.zone_id}"
    evaluate_target_health = false
  }
}
