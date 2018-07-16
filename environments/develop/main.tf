############################
# Configure the AWS Provider
############################
provider "aws" {
  access_key    = "${var.aws_access_key}"
  secret_key    = "${var.aws_secret_key}"
  region        = "${var.aws_region}"
}

############################
# Init VPC Module
############################
module "vpc" {
  source              = "../../modules/networking/vpc"

  aws_region          = "${var.aws_region}"
  vpc_cidr            = "${var.vpc_cidr}"
  project_name        = "${var.project_name}"
  environment         = "${var.environment}"
  availability_zones  = "${var.availability_zones}"
}

############################
# Init Security Groups Module
############################

module "security_groups" {
  source              = "../../modules/networking/security_group"

  vpc_id              = "${module.vpc.vpc_id}"
  environment         = "${var.environment}"
  project_name        = "${var.project_name}"
  public_ip           = "${var.public_ip}"
}

############################
# Init ALB Module
############################
module "alb" {
  source                   = "../../modules/compute/alb"

  vpc_id                   = "${module.vpc.vpc_id}"
  public_subnets           = "${module.vpc.public_subnets}"
  security_groups          = ["${module.security_groups.sg_alb_id}"]

  ssl_certificate_arn       = "${var.ssl_certificate_arn}"
  target_group_frontend_arn = "${module.target_group.alb_tg_arn}"

  environment              = "${var.environment}"
  project_name             = "${var.project_name}"

}

############################
# Init Target Groups Modules
############################
module "target_group" {
  source                   = "../../modules/compute/tg"

  vpc_id                   = "${module.vpc.vpc_id}"

  environment              = "${var.environment}"
  project_name             = "${var.project_name}"
}

############################
# Init ecs Module
############################
module "ecs" {
  source                   = "../../modules/compute/ecs"

  environment              = "${var.environment}"
  project_name             = "${var.project_name}"

  number_of_tasks          = "${var.number_of_tasks}"
  alb_target_group         = "${module.target_group.alb_tg_arn}"
}

############################
# Init AutoScaling Module
############################
module "autoscaling" {
  source                   = "../../modules/compute/autoscaling"

  environment              = "${var.environment}"
  project_name             = "${var.project_name}"
  aws_region               = "${var.aws_region}"

  subnet_ids               = ["${module.vpc.public_subnets}"]
  security_groups          = ["${module.security_groups.sg_ec2_id}"]
  availability_zones       = ["${module.vpc.availability_zones}"]

  desired_capacity         = "${var.desired_capacity}"
  max_size                 = "${var.max_size}"
  min_size                 = "${var.min_size}"
  instance_type            = "${var.instance_type}"

  public_key               = "${file("./templates/keys/ecs-develop.pub")}"
  user_data                = "${file("./templates/user-data.sh")}"

}
