module "vpc_create" {
source = "../module"
name = var.name
env = var.env[2]
}
