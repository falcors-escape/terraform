provider "aws"{
	region = "us-west-1"
}

variable "key_name"{
	description = "the name of the SSH key pair"
	type = string
}

variable "home_IP"{
	description = "My home IP"
	type = string
}

resource "aws_security_group" "ssh_only"{
	name = "ssh_only_sg"
	description = "allow SSH from home public IP"


	ingress{
		description = "SSH from home IP"
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["${var.home_IP}/32"]
		}

	egress{
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		}
}

data "aws_ami" "debian"{
	most_recent = true

	filter{
		name = "name"
		values = ["debian-12-amd64-*"]
		}

	filter{
		name = "virtualization-type"
		values = ["hvm"]
		}

	filter{
		name = "root-device-type"
		values = ["ebs"]
		}
}

resource "aws_instance" "debian_test"{
	ami = data.aws_ami.debian.id
	instance_type = "t3.micro"
	key_name = var.key_name
	security_groups = [aws_security_group.ssh_only.name]
	associate_public_ip_address = true
	instance_initiated_shutdown_behavior = "terminate"

#terminate upon shutdown section

	root_block_device{
		volume_size = 8
		volume_type = "gp2"
		}

	tags = {
		name = "Terriform-Debian-EC2"
		}
}

output "instance_public_ip"{
	description = "Public IP of the debian instance"
	value = aws_instance.debian_test.public_ip
}



