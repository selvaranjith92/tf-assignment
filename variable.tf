variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/26"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "public_subnets_cidr" {
  type    = list(string)
  default = ["10.0.1.0/28"]
}

variable "private_subnets_cidr" {
  type    = list(string)
  default = ["10.0.2.0/28"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["ap-south-1a"]
}

variable "ami-id" {
  type    = string
  default = "ami-0c50344154200fefa"
}

variable "instance-type" {
  type    = string
  default = "t2.micro"
}

variable "cluster-name" {
  type    = string
  default = "test-cluster1"
}

variable "integration_http_method" {
  type = string
  default = "GET"
  description = "The integration HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONs, ANY, PATCH) specifying how API Gateway will interact with the back end."
}

