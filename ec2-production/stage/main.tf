module "ec2-instance" {
source = "../module"
ami = var.ami[0]
name = var.name
instance_type = var.instance_type[0]
env = var.env[1]
}
