# configure aws provider
provider "aws" {
  region = var.region
}

# create vpc
module "vpc" {
  source                      = "../modules/vpc"
  region                      = var.region
  project_name                = var.project_name
  vpc_cidr                    = var.vpc_cidr
  public_subnet_az1_cidr      = var.public_subnet_az1_cidr
  public_subnet_az2_cidr      = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr = var.private_app_subnet_az2_cidr
}

# create nat gateways
module "nat_gateway" {
  source                    = "../modules/nat-gateway"
  public_subnet_az1_id      = module.vpc.public_subnet_az1_id
  internet_gateway          = module.vpc.internet_gateway
  public_subnet_az2_id      = module.vpc.public_subnet_az2_id
  vpc_id                    = module.vpc.vpc_id
  private_app_subnet_az1_id = module.vpc.private_app_subnet_az1_id
  private_app_subnet_az2_id = module.vpc.private_app_subnet_az2_id
}

# create bastion host
module "BastionHOST" {
  source               = "../modules/bastion"
  vpc_id               = module.vpc.vpc_id
  public_subnet_az1_id = module.vpc.public_subnet_az1_id
  public_subnet_az2_id = module.vpc.public_subnet_az2_id
}

# create security group
module "security_group" {
  source = "../modules/security-groups"
  vpc_id = module.vpc.vpc_id
}

# launch ec2 instances in private subnet
module "ec2" {
  source                    = "../modules/ec2"
  vpc_id                    = module.vpc.vpc_id
  private_app_subnet_az1_id = module.vpc.private_app_subnet_az1_id
  private_app_subnet_az2_id = module.vpc.private_app_subnet_az2_id

  depends_on = [module.nat_gateway]

}

module "application_load_balancer" {
  source                = "../modules/elb"
  project_name          = module.vpc.project_name
  alb_security_group_id = module.security_group.alb_security_group_id
  public_subnet_az1_id  = module.vpc.public_subnet_az1_id
  public_subnet_az2_id  = module.vpc.public_subnet_az2_id
  vpc_id                = module.vpc.vpc_id
  instance_alb          = module.ec2.instance_alb
  instance_alb_second   = module.ec2.instance_alb_second
}

