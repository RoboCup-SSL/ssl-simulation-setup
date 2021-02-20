variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default     = "10.1.0.0/16"
}
variable "cidr_subnet" {
  description = "CIDR block for the subnet"
  default     = "10.1.0.0/24"
}
variable "region" {
  description = "The region Terraform deploys your instance"
}
variable "instance_type" {
  description = "The AWS EC2 instance type"
  default = "c5a.xlarge"
}
variable "root_domain" {
  description = "The external domain at which the instance will be reachable"
}