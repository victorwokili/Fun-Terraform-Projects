#We are looking to SSH into the machine so we would need to setup a data key
terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.1.0"
    }
  }

  cloud {
    organization = "Wokili"

    workspaces {
      name = "provisioners"
    }
  }
}


provider "aws" {
  # Configuration options
  region = "us-west-1"
}

#default VPC data source
# variable "vpc_id" {}

data "aws_vpc" "main" {
  id = "vpc-04217d85953b81898"
}

#Issue with M1 Macs
# data "template_file" "user_data" {
#     template = file("./userdata.yaml")
# }

#Create Security group and set port 80
resource "aws_security_group" "myServerSG" {
  name        = "myServerSG"
  description = "my server security grroup"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] 
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false

  },
  {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["45.25.83.246/32"] 
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }
  ]

  egress {
    description = "outgoign traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
    security_groups = []
    self = false
  }

  tags = {
    Name = "allow_tls"
  }
}



#Key pair creation for instance SSHability
resource "aws_key_pair" "cali" {
  key_name   = "cali-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHtV3wveKq+oa93JlhsPs8kTQHN8VRYXh0UuOiDzdVW+o5hGXrklubmpGIOLnF2JEr0ou1RhSTnGAlyAplY52pYWLn86DIPoNAAYD+AoBDOfSd56o2MZBFtoJCjSaFTSSMEP00XcOoCm2dS+/kt4E14X5Pw6kSgg5AKl06YTMdAvRhiyV5DE1i5/bkPqk47jbvNQU1EEmx/433OmkrjE8voDRiC0pmVy/kFbPjZ1nG26YyQDZVHX1jNqi2q/Iiv+CvmGFP3BDhWxYm7Qs5G4YjK2J8/PowRzn88Tk2jdaV2+VKJDG6mjmEboi0LhLsE4dV/zvrbdCROW9tBLBbG43RETmZAM2HlAs8x/tOYEmiE5plTordghrJhtp0GAwfZXuvRsUJVseb9lFCfezKjVkoNk+ZyD8mKVJDt8xa78sqM1YajdmxUft91oB5p90opBbELh6sSGFL2To6Sh7vkVhS9LewtDBDkHCUodA6r9gaDTpYlXiq030vfNq3oPT6fnE= victorw@Victor-Ws-Air.attlocal.net"
}

#EC2 1
resource "aws_instance" "my_server1" {
  ami           = "ami-04669a22aad391419"
  instance_type = "t2.micro"
  key_name = aws_key_pair.cali.key_name
vpc_security_group_ids = [aws_security_group.myServerSG.id] #use .id not .vpc_id
#vpc_security_group_ids = ["myServerSG"] <-- Does not give issues

#template = file("./userdata.yaml")
user_data = file("./userdata.sh")
#user_data = data.template_file.user_data.rendered #render user data file
#user_data = templatefile().user_data.rendered("./userdata.yaml")
#user_data = templatefile("${path.module}/userdata.yaml")
# user_data = <<EOF
# #		#!/bin/bash
# 		yum update -y
# 		yum install -y httpd.x86_64
# 		systemctl start httpd.service
# 		systemctl enable httpd.service
# 		echo ?Hello World from $(hostname -f)? > /var/www/html/index.html
# 	EOF

  tags = {
    Name = "myServer1"
  }
}

#EC2 2
resource "aws_instance" "my_server2" {
  ami           = "ami-04669a22aad391419"
  instance_type = "t2.micro"
  key_name = aws_key_pair.cali.key_name
vpc_security_group_ids = [aws_security_group.myServerSG.id]
#user_data = file("./userdata.yaml")
user_data = <<EOF
		#!/bin/bash
		yum update -y
		yum install -y httpd.x86_64
		systemctl start httpd.service
		systemctl enable httpd.service
		echo ?Hello World from Server 2, $(hostname -f)? > /var/www/html/index.html
	EOF

  tags = {
    Name = "myServer2"
  }
}



output"public_ip1"{
    value = aws_instance.my_server1.public_ip
}

output"public_ip2"{
    value = aws_instance.my_server2.public_ip
}