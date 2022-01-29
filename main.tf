#Install provider locally. AWS provider gives us access to the entire API of AWS. We can work with exposed AWS resources using this provider.

#Terraform is declarative and idempotent

# Set environmental variables for your credentials and region. so that there is not need to hard-code them into the config file.
provider "aws" {}
    #region = "us-east-1"
    #access_key = "AKIA5BEK5N4TEBXQVLOH"
    #secret_key = "0SRb74hsl0riSORHPaS+AM4/5jpgMpLK1ZF5XbqK"

#variable "subnet_cidr_block" {
    #description = "subnet cidr block"
#}

#variable "vpc_cidr_block" {
    #description = "vpc cidr block"
#}

#variable "environment" {
    #description = "deployment environment"
#}

variable "cidr_blocks" {
    description = "cidr blocks and name tags for vpc and subnet"
    type = list(object({
        cidr_block = string
        name = string  
    }))
}

variable avail_zone {}

#First step is to do terraform init" for the above.
#Next is to provide our resources. First name is the official name by aws, and the other name is provided by us.
# We name our resources by using tags. The tags can have key-value pairs.

resource "aws_vpc" "development-vpc" {
    #cidr_block = var.vpc_cidr_block
    cidr_block = var.cidr_blocks[0].cidr_block
    tags = {
        Name: var.cidr_blocks[0].name
        #Name: var.environment   #"development"                           
    }
}

#From the above tag's key-value pair, we have mykey = myvalue
#Define which VPC our subnet will be created in. We reference the vpc that has not yet been created by doing below.

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.development-vpc.id
    #cidr_block = var.subnet_cidr_block                      #"10.0.10.0/24"
    cidr_block = var.cidr_blocks[1].cidr_block
    availability_zone = var.avail_zone        #availability_zone = "us-east-1a"
    tags = {
        Name: var.cidr_blocks[1].name #Name: "subnet-1-dev"
    }
}



#Do terraform apply with the above

#If you want to create a subnet in an existing VPC, you need the ID of the VPC. You can query AWS using the provider. This is where Data Sources come in place. They allow data to be fetched for use in TF configuration. "Resource" lets you create new resources, but data lets you fecth existing resources. These are the two components provided by your provider.

data "aws_vpc" "existing_vpc" {
    default = true
}

#The result of the above query (data "aws"....) will be referenced by the subnet config below.

resource "aws_subnet" "dev-subnet-2" {
    vpc_id = data.aws_vpc.existing_vpc.id     # We reference the output from the above config)
    cidr_block = "172.31.96.0/20"            # We update the cidr block to that of our existing vpc
    availability_zone = "us-east-1b"
    tags = {
        Name: "subnet-2-default"
    }
}

resource "aws_subnet" "dev-subnet-3" {
    vpc_id = data.aws_vpc.existing_vpc.id     # We reference the output from the above config)
    cidr_block = "172.31.112.0/20"            # We update the cidr block to that of our existing vpc
    availability_zone = "us-east-1c"
    tags = {
        Name: "subnet-3-default"
    }
}

output "dev-vpc-id" {
    value = aws_vpc.development-vpc.id
}

output "dev-subnet-id" {
    value = aws_subnet.dev-subnet-1.id
}




#Apply "terraform apply" with the above

