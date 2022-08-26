module "alb-asg" {
source = "../alb-asg-module"
alb_name = var.alb_name
tg_name = var.tg_name
}
