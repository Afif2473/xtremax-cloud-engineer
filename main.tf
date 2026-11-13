module "vpc" {
  source = "./modules/vpc"

  project_name             = var.project_name
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  azs                      = var.azs
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
}

module "iam" {
  source = "./modules/iam"

  project_name     = var.project_name
  environment      = var.environment
  ssm_db_param_arn = var.ssm_db_param_arn
  log_group_arn    = var.log_group_arn
}

module "rds" {
  source = "./modules/rds"

  project_name            = var.project_name
  environment             = var.environment
  private_db_subnet_ids   = module.vpc.private_db_subnet_ids
  rds_sg_id               = module.vpc.rds_sg_id
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  engine_version          = var.engine_version
  db_instance_class       = var.db_instance_class
  allocated_storage       = var.allocated_storage
  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection
}

module "alb_asg" {
  source = "./modules/alb_asg"

  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnet_ids
  private_app_subnet_ids    = module.vpc.private_app_subnet_ids
  alb_sg_id                 = module.vpc.alb_sg_id
  ec2_sg_id                 = module.vpc.ec2_sg_id
  iam_instance_profile_name = module.iam.ec2_instance_profile_name
  wordpress_ami_id          = var.wordpress_ami_id
  instance_type             = var.instance_type
  alb_acm_certificate_arn   = var.alb_acm_certificate_arn
  alb_ssl_policy            = var.alb_ssl_policy
  asg_min_size              = var.asg_min_size
  asg_max_size              = var.asg_max_size
  asg_desired_capacity      = var.asg_desired_capacity
  scale_up_cpu_threshold    = var.scale_up_cpu_threshold
  scale_down_cpu_threshold  = var.scale_down_cpu_threshold
  alarm_period              = var.alarm_period
  alarm_evaluation_periods  = var.alarm_evaluation_periods
  db_endpoint               = module.rds.db_instance_endpoint
  db_name                   = module.rds.db_name
}

module "cloudfront" {
  source = "./modules/cloudfront"

  project_name           = var.project_name
  environment            = var.environment
  alb_dns_name           = module.alb_asg.alb_dns_name
  cf_acm_certificate_arn = var.cf_acm_certificate_arn
  price_class            = var.price_class
}
