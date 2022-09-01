variable "ami" {
description = "Provide the AMI ID"
type = list
default = ["ami-0568773882d492fc8", "ami-0ee5c62243ab25259", "ami-092b43193629811af", "ami-005074b2b824595f4"]
}
variable "instance_type" {
description = "Provide the Instance Type"
type = list
default = ["t3.micro", "t3.small", "t3.medium", "t3.large", "t3.xlarge"]
}
variable "name" {
description = "Provide the Name of the EC2 Instance"
type = string
default = "Test"
}
variable "env" {
description = "Provide the Environment name as dev, stage or prod"
type = list
default = ["dev", "stage", "prod"]
}
