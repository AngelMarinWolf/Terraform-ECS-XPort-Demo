output "sg_alb_id" {
  description = "Returns the ID of the ELB's Security Group."
  value       = "${aws_security_group.load_balancer.id}"
}

output "sg_ec2_id" {
  description = "Returns the ID of the EC2's Security Group."
  value       = "${aws_security_group.instances.id}"
}
