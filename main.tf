resource "aws_vpc" "library-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

module "library-subnet" {
    source = "./modules/subnet"
    subnet_cidr_block = var.subnet_cidr_block
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.library-vpc.id
}

module "library-server" {
    source = "./modules/webserver"
    my_ip = var.my_ip
    env_prefix = var.env_prefix
    public_key_location = var.public_key_location
    instance_type = var.instance_type
    avail_zone = var.avail_zone
    image_name = var.image_name
    vpc_id = aws_vpc.library-vpc.id
    subnet_id = module.library-subnet.subnet.id
}
