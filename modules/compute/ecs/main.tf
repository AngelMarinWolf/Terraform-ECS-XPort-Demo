############################
# ERC Repositories
############################
resource "aws_ecr_repository" "repository" {
  name = "${var.project_name}"
}

############################
# ECS Task Definition
############################
data "template_file" "template" {
  template = "${file("./template/nginx-container.json")}"

  vars {
    project_name  = "${var.project_name}"
    environment   = "${var.environment}"
  }
}

resource "aws_ecs_task_definition" "task" {
  family                = "${var.family_name}"
  container_definitions = "${data.template_file.template.rendered}"
}

############################
# ECS Cluster
############################
resource "aws_ecs_cluster" "cluster" {
  name = "ecs-${var.project_name}-${var.environment}"
}

############################
# ECS Service
############################
resource "aws_ecs_service" "service" {
  name            = "${var.project_name}-service-${var.environment}"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.task.arn}"
  desired_count   = "${var.number_of_tasks}"
  launch_type     = "EC2"

  deployment_maximum_percent          = "200"
  deployment_minimum_healthy_percent  = "50"

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  load_balancer {
    target_group_arn = "${var.alb_target_group}"
    container_name   = "${var.project_name}-application"
    container_port   = 80
  }
}
