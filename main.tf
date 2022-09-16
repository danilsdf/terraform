provider "aws" {
    region = "eu-west-3"
}

resource "aws_vpc" "library-vpc" {
    cidr_block = var.cidrs_block[0].cidr_block
    tags = {
        Name: var.cidrs_block[0].name
        vpc_env: "dev"
    }
}

resource "aws_subnet" "dev-subnet-library" { 
    vpc_id = aws_vpc.development-vpc.id
    cidr_block = var.cidrs_block[1].cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: var.cidrs_block[1].name
    }
}