provider "aws" {
    region = "eu-west-3"
}

resource "aws_vpc" "library-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "library-subnet-1" { 
    vpc_id = aws_vpc.library-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

resource "aws_route_table" "library-route-table" {
    vpc_id = aws_vpc.library-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.library-igw.id
    }

    tags = {
        Name: "${var.env_prefix}-rtb"
    }
}

resource "aws_internet_gateway" "library-igw" {
    vpc_id = aws_vpc.library-vpc.id

    tags = {
        Name: "${var.env_prefix}-igw"
    }
}

resource "aws_route_table_association" "a-rtb-subnet" {
    subnet_id = aws_subnet.library-subnet-1.id
    route_table_id = aws_route_table.library-route-table.id
}

resource "aws_security_group" "library-sg" {
    name = "library-sg"
    vpc_id = aws_vpc.library-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ var.my_ip ]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1" //any
        cidr_blocks = [ "0.0.0.0/0" ]
        prefix_list_ids = []
    }

    tags = {
        Name: "${var.env_prefix}-sg"
    }
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

output "aws_public_ip" {
    value = aws_instance.library-server.public_ip
}

resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = file(var.public_key_location)
}

resource "aws_instance" "library-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id // required
    instance_type = var.instance_type // required

    subnet_id = aws_subnet.library-subnet-1.id
    vpc_security_group_ids = [aws_security_group.library-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

    user_data = file("entry_script.sh")

    tags = {
        Name: "${var.env_prefix}-server"
    }
}

