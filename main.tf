# configured aws provider with proper credentials
provider "aws" {
  region    = "us-east-2"
  shared_config_files      = ["/Users/austi/.aws/conf"]
  shared_credentials_files = ["/Users/austi/.aws/credentials"]

  profile                  = "austin"

}

# Create a remote backend for your terraform 
terraform {
  backend "s3" {
    bucket = "may-class-devops-austin"
    region = "us-east-1"
    profile = "austin"
    key    = "ansible-ftstate"

  }
}


# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {

  tags    = {
    Name  = "default vpc"
  }
}


# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


# create default subnet if one does not exit
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags   = {
    Name = "default subnet"
}
}


# create security group for the ec2 instance
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2 security group"
  description = "allow access on ports 8080 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  # allow access on port 8080
  ingress {
    description      = "http proxy access"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # allow access on port 22
  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "http proxy-nginx access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "http nginx access"
    from_port        = 9090
    to_port          = 9090
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "mysql access"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "Ec2-instances security group"
  }
}


# use data source to get a registered amazon linux 2 ami
data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# launch the ec2 instance and install website

resource "aws_instance" "ec2_instance1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.small"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name               = "may_key"
  user_data            = "${file("jenkins_install.sh")}"

  tags = {
    Name = "Jenkins-Ansible-Server"

  }
}

resource "aws_instance" "ec2_instance2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name               = "may_key"

  tags = {
    Name = "Database-server"
  }
}

resource "aws_instance" "ec2_instance3" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name               = "may_key"

  tags = {
    Name = "Nginx-Server"
  }
}

resource "aws_instance" "ec2_instance4" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name               = "may_key"

  tags = {
    Name = "Apache-Server"
  }
}

#output "ec2_global_ips" {
#  value = ["${aws_instance.ec2_instance1.*.public_ip}"]
#  value = ["${}"]
#}
