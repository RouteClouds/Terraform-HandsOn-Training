# Application Stack Module - Main Configuration

# Create VPC using module from Lab 1
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = var.environment != "production"

  tags = merge(
    {
      Environment = var.environment
    },
    var.tags
  )
}

# Create Security Groups
module "security_group" {
  source = "../security-group"

  name        = "${var.environment}-app-sg"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment

  ingress_rules = concat(
    var.environment == "production" ? [] : [{
      port        = 22
      protocol    = "tcp"
      cidr_blocks = [var.admin_cidr]
      description = "SSH Access"
    }],
    [{
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    }]
  )
}

# Create EC2 Instances
module "instances" {
  source = "../../07-lab2-manifests/modules/aws-ec2-instance"
  count  = var.instance_count

  instance_name = "${var.environment}-app-${count.index + 1}"
  instance_type = var.instance_type
  subnet_id     = element(
    var.environment == "production" ? module.vpc.private_subnets : module.vpc.public_subnets,
    count.index % length(var.availability_zones)
  )

  vpc_security_group_ids = [module.security_group.security_group_id]
  key_name              = var.key_name
  associate_public_ip   = var.environment != "production"

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    environment = var.environment
  })

  tags = merge(
    {
      Environment = var.environment
      Role        = "application"
    },
    var.tags
  )
}

# Create ALB (Production Only)
module "alb" {
  source = "../alb"
  count  = var.environment == "production" ? 1 : 0

  name               = "${var.environment}-alb"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnets
  security_group_ids = [module.security_group.security_group_id]
  instance_ids       = module.instances[*].instance_id
  environment        = var.environment

  enable_https      = true
  certificate_arn   = var.certificate_arn
  enable_access_logs = true
  access_logs_bucket = var.access_logs_bucket

  tags = var.tags
}