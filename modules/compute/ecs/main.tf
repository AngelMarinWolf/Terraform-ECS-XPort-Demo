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
  template = "${file("${path.module}/templates/nginx-container.json")}"

  vars {
    project_name  = "${var.project_name}"
    environment   = "${var.environment}"
  }
}

resource "aws_ecs_task_definition" "task" {
  family                    = "${var.project_name}-application-${var.environment}"
  container_definitions     = "${data.template_file.template.rendered}"
  network_mode              = "bridge"
  requires_compatibilities  = ["EC2"]
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
    container_name   = "${var.project_name}-application-${var.environment}"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

############################
# ECS Scaling policies
############################
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 5
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name                    = "ScalingMemory"
  policy_type             = "TargetTrackingScaling"
  resource_id             = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension      = "ecs:service:DesiredCount"
  service_namespace       = "ecs"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 80
    scale_in_cooldown = 60
    scale_out_cooldown = 60
  }

  depends_on = ["aws_appautoscaling_target.ecs_target"]
}
