# instance.tf

resource "aws_key_pair" "kp"{
  key_name    = "deployer_key"
  public_key  = var.public_key
}

data "aws_ami" "ubuntu"{
  most_recent = true
  owners      = ["099720109477"] # canonical

  filter {
    name  = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name    = "virtualization-type"
    values   = ["hvm"]  
  }
}

resource "aws_iam_instance_profile" "me_iam"{
  name_prefix = "${var.name}-"
  role        = var.role.name
}

resource "aws_instance" "me"{
  ami                     = var.ami_id == "nope" ? data.aws_ami.ubuntu.id : var.ami_id 
  instance_type           = var.instance_type
  subnet_id               = var.subnet.id
  iam_instance_profile    = aws_iam_instance_profile.me_iam.name 
  key_name                = aws_key_pair.kp.key_name
  vpc_security_group_ids  = [aws_security_group.fw.id]
  user_data               = var.user_data.rendered
  root_block_device {
    volume_size = var.ebs_size
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.me.id
  allocation_id = var.eip_id
}

resource "aws_security_group" "fw"{
	name					= "dummy"
	description		= "security group for origin host"
	vpc_id				= var.subnet.vpc_id
}

resource "aws_security_group_rule" "egress"{
  type        = "egress"
	protocol		= "-1"
	from_port		= 0
	to_port			= 0
	cidr_blocks	= ["0.0.0.0/0"]
  security_group_id = aws_security_group.fw.id
}

resource "aws_security_group_rule" "ingress_tcp"{
  count     = length(var.tcp_ports)
  type      = "ingress"
  protocol  = "tcp"
  from_port = element(var.tcp_ports, count.index)
  to_port   = element(var.tcp_ports, count.index)
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.fw.id
}


output "private_ip"{
  value = aws_instance.me.private_ip
}

output "public_ip"{
  value = aws_instance.me.public_ip
}

output "security_group"{
  value = aws_security_group.fw.id
}

