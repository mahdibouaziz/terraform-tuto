terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-3"
}

#defie a variable that contains cidr blocks for dev-vpc and dev-subnet
variable "cidr_blocks" {
  description = "cidr blocks for dev-vpc and dev-subnet"
  type = list(object({
    cidr_block = string
    name = string
  }))
}

# Create a VPC
resource "aws_vpc" "development-vpc" {
  cidr_block = var.cidr_blocks[0].cidr_block
  tags = {
      Name = var.cidr_blocks[0].name
  }
}

# create a subnet for the VPC
resource "aws_subnet" "dev-subnet-1" {
  vpc_id     = aws_vpc.development-vpc.id
  cidr_block =  var.cidr_blocks[1].cidr_block
  availability_zone = "eu-west-3a"
  tags = {
      Name =  var.cidr_blocks[1].name
  }
}

#query the defaul vpc
data "aws_vpc" "existing_vpc" {
  default = true
}

# create a subnet for the default VPC
resource "aws_subnet" "dev-subnet-2" {
  vpc_id     = data.aws_vpc.existing_vpc.id
  cidr_block = "172.31.48.0/20"
  availability_zone = "eu-west-3a"
  tags = {
      Name = "dev-subnet-2-default"
  }
}

# specify the output data
output "dev-vpc-id" {
  value = aws_vpc.development-vpc.id
}

output "dev-subnet-id" {
  value = aws_subnet.dev-subnet-1.id
}