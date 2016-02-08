provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}
provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_api_key}"
}

/* Setup ECS IAM role and policy */
/* http://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html */
resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.iam_name}"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "attach_ecs_policy" {
    name = "AmazonEC2ContainerServiceforEC2Role"
    roles = ["${aws_iam_role.ecs_instance_role.name}"]
    policy_arn = "${var.ecs_service_policy_arn}"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
    name = "IAMInstanceRole"
    roles = ["${aws_iam_role.ecs_instance_role.name}"]
}

/* Create ECS cluster */
resource "aws_ecs_task_definition" "docker_compose_demo" {
  depends_on = ["aws_autoscaling_group.ecs-cluster"]
  family = "${var.ecs_task_definition_name_name}"
  container_definitions = "${file("container-definitions.json")}"
}

resource "aws_ecs_cluster" "docker_compose_demo_cluster" {
  name = "${var.cluster_name}"
}

resource "aws_ecs_service" "docker_compose_demo_service" {
  depends_on = ["aws_iam_policy_attachment.attach_ecs_policy", "aws_autoscaling_group.ecs-cluster"]
  name = "${var.ecs_service_name}"
  cluster = "${aws_ecs_cluster.docker_compose_demo_cluster.id}"
  task_definition = "${aws_ecs_task_definition.docker_compose_demo.arn}"
  desired_count = 1
}

resource "aws_launch_configuration" "ecs" {
  depends_on = ["aws_iam_role.ecs_instance_role"]
  name = "${var.launch_configuration_name}"
  image_id = "${var.ami}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_instance_profile.id}"
  key_name = "${var.key_name}"
  security_groups = ["${split(",", var.security_group_ids)}"]
  user_data = <<EOF
#!/bin/bash
mkdir -p /etc/ecs
touch /etc/ecs/ecs.config
echo ECS_CLUSTER=${var.cluster_name} > /etc/ecs/ecs.config
echo ECS_LOGFILE=/var/log/ecs-agent.log >> /etc/ecs/ecs.config
echo ECS_ENGINE_AUTH_TYPE=docker >> /etc/ecs/ecs.config
echo ECS_ENGINE_AUTH_DATA='{"${var.registry_url}":{"username":"${var.registry_username}","email":"${var.registry_email}","password":"${var.registry_password}"}}' >> /etc/ecs/ecs.config
EOF
}

resource "aws_elb" "ecs-elb" {
  name = "${var.elb_name}"
  availability_zones = ["${split(",", var.availability_zones)}"]
  access_logs {
    bucket = "${var.elb_bucket_name}"
    interval = 60
  }
  listener {
    instance_port = 80
    instance_protocol = "TCP"
    lb_port = 80
    lb_protocol = "TCP"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:80"
    interval = 30
  }
  connection_draining = true
  connection_draining_timeout = 60
  cross_zone_load_balancing = true
}

resource "aws_proxy_protocol_policy" "ws" {
  load_balancer = "${aws_elb.ecs-elb.name}"
  instance_ports = ["80"]
}

resource "aws_autoscaling_group" "ecs-cluster" {
  availability_zones = ["${split(",", var.availability_zones)}"]
  name = "ECS ${var.cluster_name}"
  min_size = "${var.min_size}"
  max_size = "${var.max_size}"
  desired_capacity = "${var.desired_capacity}"
  load_balancers = ["${aws_elb.ecs-elb.name}"]
  health_check_type = "EC2"
  launch_configuration = "${aws_launch_configuration.ecs.name}"
  health_check_grace_period = "${var.health_check_grace_period}"

  tag {
    key = "Env"
    value = "${var.environment_name}"
    propagate_at_launch = true
  }

  tag {
    key = "Name"
    value =  "ECS ${var.cluster_name}"
    propagate_at_launch = true
  }
}

resource "cloudflare_record" "docker_compose_demo" {
  domain = "${var.cloudflare_domain}"
  name = "dcd"
  value = "${aws_elb.ecs-elb.dns_name}"
  type = "CNAME"
  ttl = 1
}
