#######################
# Security Group ELB
#######################
resource "aws_security_group" "load_balancer" {
  name        = "Load_Balancer"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
    Name        = "sg-elb-${var.environment}"
    Environment = "${var.environment}"
    Project     = "${var.project_name}"
  }
}

#######################
# Security Group EC2
#######################
resource "aws_security_group" "instances" {
  name        = "Instances"
  description = "Allow HTTP inbound traffic only from ELB"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups  = ["${aws_security_group.load_balancer.id}"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.jenkins.id}"]
  }

  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
    Name        = "sg-ec2-${var.environment}"
    Environment = "${var.environment}"
    Project     = "${var.project_name}"
  }
}

#######################
# Security Group Jenkins
#######################
resource "aws_security_group" "jenkins" {
  name        = "Jenkins"
  description = "Allow HTTP inbound traffic only from port 8080 and SSH Access from the office"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${var.public_ip}"]
  }

  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

  tags {
    Name        = "sg-ec2-${var.environment}"
    Environment = "${var.environment}"
    Project     = "${var.project_name}"
  }
}
