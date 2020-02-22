#variables.tf

variable "project_domain"{}
variable "public_key" {}
variable "subnet"{}
variable "tcp_ports"{}
variable "name"{}

variable "role"{}

variable "instance_type"{
  default = "t2.nano"
}

variable "ebs_size" {
  default = 8 
}

variable "ami_id"{
  default = "nope"
}

variable "user_data"{}

