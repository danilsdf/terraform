module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "library-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.avail_zone]
  public_subnets  = [var.subnet_cidr_block]

  tags = {
    Name: "${var.env_prefix}-vpc"
  }

  public_subnet_tags = {
    Name: "${var.env_prefix}-subnet-1"
  }
}

module "library-server" {
    source = "./modules/webserver"
    my_ip = var.my_ip
    env_prefix = var.env_prefix
    public_key_location = var.public_key_location
    instance_type = var.instance_type
    avail_zone = var.avail_zone
    image_name = var.image_name
    vpc_id = module.vpc.vpc_id
    subnet_id = module.vpc.public_subnets[0]
}
