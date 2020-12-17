locals {
  name        = "docker-rails"
  environment = "development"

  # This is the convention we use to know what belongs to each other
  ec2_resources_name = "${local.name}-${local.environment}"
}

terraform {
  backend "http" {}
}

provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  region                  = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "docker-rails-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  enable_nat_gateway = false
  single_nat_gateway = false


  public_subnet_tags = {
    Name = "docker-rails-public"
  }

  private_subnet_tags = {
    Name = "docker-rails-private"
  }


  tags = {
    Owner       = "Cornflakecode"
    Name        = local.name
    Environment = local.environment
  }

  vpc_tags = {
    Name = "docker-rails-vpc"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


// module "bastion" {
// source        = "./bastion"
// ami           = data.aws_ami.ubuntu.id
// instance_type = "t2.nano"
// ssh_key_name  = "test"

// vpc_id    = module.vpc.vpc_id
// subnet_id = module.vpc.public_subnets[0]

// }


module "ecs" {
  source             = "./ecs"
  aws_ecr_repository = "123523539192.dkr.ecr.ap-southeast-1.amazonaws.com/rails"
  subnets            = module.vpc.public_subnets
  cpu                = 1024
  memory             = 2048
  rails_port         = 3000
  vpc_id             = module.vpc.vpc_id

  // tags = {
  //   Owner       = "Cornflakecode"
  //   Name        = local.name
  //   Environment = local.environment
  // }

}

# module "ec2_profile" {
#   source = "./ecs-instance-profile"

#   name = local.name

#   tags = {
#     Environment = local.environment
#   }
# }
