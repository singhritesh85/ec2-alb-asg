module "ec2-instance" {
source = "../module"
ami = var.ami[0]
name = var.name
instance_type = var.instance_type[1]
env = var.env[2]
}
