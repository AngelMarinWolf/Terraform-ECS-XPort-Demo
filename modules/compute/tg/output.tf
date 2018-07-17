output "alb_tg_id" {
  description = "Application Load Balancer - Target Group - Backend - ID"
  value       = "${aws_lb_target_group.target_group.id}"
}
output "alb_tg_arn" {
  description = "Application Load Balancer - Target Group - Backend - ARN"
  value       = "${aws_lb_target_group.target_group.arn}"
}
