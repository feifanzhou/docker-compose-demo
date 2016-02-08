variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-east-1"
}
variable "ami" {
  /* us-east-1, Ubuntu Linux, SSD EBS */
  /* default = "ami-d05e75b8" */
  /* us-east-1, ECS-optimized AMI */
  default = "ami-ddc7b6b7"
}

variable "iam_name" {
  default = "IAMInstanceRole"
}

variable "cluster_name" {
  default = "Docker-Compose-Demo"
}
variable "key_name" {
  default = "Stoat-Ops"
}
variable "availability_zones" {
    default = "us-east-1b,us-east-1c,us-east-1d,us-east-1e"
}

variable "security_group_ids" {
    default = "sg-26d69740"
}

variable "instance_type" {
    default = "t2.micro"
    description = "Name of the AWS instance type"
}

variable "min_size" {
    default = "1"
    description = "Minimum number of instances to run in the group"
}

variable "max_size" {
    default = "5"
    description = "Maximum number of instances to run in the group"
}

variable "desired_capacity" {
    default = "1"
    description = "Desired number of instances to run in the group"
}

variable "health_check_grace_period" {
    default = "300"
    description = "Time after instance comes into service before checking health"
}

variable "cluster" {
    default = "default"
    description = "The name of the ECS cluster."
}

variable "registry_url" {
    default = "https://index.docker.io/v1/"
    description = "Docker private registry URL, defaults to Docker index"
}

variable "registry_email" {
    default = "feifan@sendo.me"
    description = "Docker private registry login email address"
}

variable "registry_username" {
  description = "Docker registry username"
}
variable "registry_password" {
  description = "Docker registry password"
}
variable "registry_auth" {
  description = "Docker login auth token"
}

variable "environment_name" {
    default = ""
    description = "Environment name to tag EC2 resources with (tag=environment)"
}

variable "ecs_service_name" {
    default = "Docker-Compose-Demo"
    description = "ECS Service name"
}
variable "ecs_task_definition_name_name" {
    default = "Docker-Compose-Demo"
    description = "ECS Task Definition name"
}
variable "ecs_service_policy_arn" {
  default = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

variable "launch_configuration_name" {
  default = "ECS Docker-Compose-Demo"
}

variable "elb_name" {
  default = "docker-compose-demo-elb"
  description = "Name for load balancer"
}
variable "elb_bucket_name" {
  default = "docker-compose-demo-elb-logs"
  description = "ELB access logs bucket name"
}

variable "cloudflare_api_key" {}
variable "cloudflare_email" {
  default = "team@sendo.me"
}
variable "cloudflare_domain" {
  default = "wht.tf"
}