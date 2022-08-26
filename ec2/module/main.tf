module "my-ec2" {
count = 2
source = "../ec2-module"
ami = var.ami
instance_type = var.instance_type
key_name = var.key_name
name = "${var.name}-${count.index+1}"
orgname = var.orgname
security_group_name = "${var.security_group_name}-${count.index+1}"
}
