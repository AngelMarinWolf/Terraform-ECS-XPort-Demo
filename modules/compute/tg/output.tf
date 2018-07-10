output "alb_tg_fe_id" {
  description = "Application Load Balancer - Target Group - Backend - ID"
  value       = "${aws_lb_target_group.target_group_frontend.id}"
}
output "alb_tg_fe_arn" {
  description = "Application Load Balancer - Target Group - Backend - ARN"
  value       = "${aws_lb_target_group.target_group_frontend.arn}"
}
