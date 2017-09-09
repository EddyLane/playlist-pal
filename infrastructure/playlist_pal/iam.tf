resource "aws_iam_role" "ecs_service" {
  name = "playlist-pal.${var.environment}.ecs_role"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com",
          "ecs.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_iam" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role = "${aws_iam_role.ecs_service.name}"
}

resource "aws_iam_role_policy" "ecs_service" {
  name = "playlist-pal.${var.environment}.ecs_policy"
  role = "${aws_iam_role.ecs_service.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets",
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "autoscaling:DescribeAutoScalingInstances",
        "ecs:ListServices",
        "ecs:DescribeTasks",
        "ecs:DescribeServices"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_instance_profile" "ecs_service" {
  name = "ecs_service.${var.environment}"
  role = "${aws_iam_role.ecs_service.name}"
}