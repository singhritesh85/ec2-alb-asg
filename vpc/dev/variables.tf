variable "name" {
description = "Provide the name of VPC"
type = string
default = "VPC-A"
}
variable "env" {
description = "Provide the name of the Environment"
type = list
default = ["dev", "stage", "prod"]
}
