variable "ami" {
description = "Provide the AMI ID"
type = string
default = "ami-0568773882d492fc8"
}
variable "instance_type" {
description = "Provide the Instance Type"
type = string
default = "t3.micro"
}
variable "key_name" {
description = "Provide the Key Name"
type = string
default = "testkey"
}
variable "orgname" {
description = "Provide the Organisation Name"
type = string
default = "Test2Organisation"
}
variable "name" {
description = "Provide the Instance Name"
type = string
default = "Test"
}
variable "security_group_name" {
description = "Provide the security group name"
type = string
default = "MySG"
}
