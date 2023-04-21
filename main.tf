terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}
# Create VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}
# Create public subnet
resource "aws_subnet" "example_public_subnet" {
  cidr_block = "10.0.1.0/24"
    vpc_id     = aws_vpc.example_vpc.id

      tags = {
          Name = "example-public-subnet"
	    }
	    }

	    # Create private subnet
	    resource "aws_subnet" "example_private_subnet" {
	      cidr_block = "10.0.2.0/24"
	        vpc_id     = aws_vpc.example_vpc.id

		  tags = {
		      Name = "example-private-subnet"
		        }
			}

			# Create internet gateway
			resource "aws_internet_gateway" "example_igw" {
			  vpc_id = aws_vpc.example_vpc.id

			    tags = {
			        Name = "example-igw"
				  }
				  }
# Attach internet gateway to VPC
resource "aws_internet_gateway_attachment" "example" {
  vpc_id       = aws_vpc.example_vpc.id
    internet_gateway_id = aws_internet_gateway.example_igw.id
    }

# Create NAT gateway
resource "aws_nat_gateway" "example_nat_gateway" {
  allocation_id = aws_eip.example_eip.id
    subnet_id     = aws_subnet.example_public_subnet.id

      tags = {
          Name = "example-nat-gateway"
	    }
	    }

# Create Elastic IP for NAT gateway
resource "aws_eip" "example_eip" {
  vpc = true

    tags = {
        Name = "example-eip"
	  }
	  }



# Create KMS CMK key
resource "aws_kms_key" "example_kms_key" {
  description = "Example CMK key"
  }

#creating ec2 instance with kms key
resource "aws_instance" "app server" {
  ami           = "ami-0c55b159cbfafe1f0" 
    instance_type = "t2.micro" 

      subnet_id = aws_subnet.example_private_subnet.id
      
 # Encrypt EBS volumes with the CMK Key
   ebs_block_device {
       device_name = "/dev/xvdf"
           kms_key_id   = aws_kms_key.example.arn
	     }
              tags = {
	          Name = "example_instance"
		    }
		    }

						      
# Create RDS instance in private subnet
  resource "aws_db_instance" "example_rds_instance" { 
            engine           = "mysql"
	    instance_class   = "db.t2.micro"  
	      allocated_storage = 20  
	        storage_type     = "gp2"

		  vpc_security_group_ids = [aws_security_group.example_db_sg.id]
		    subnet_group_name     = aws_db_subnet_group.example_db_subnet_group.name

 # Encrypt RDS instance with CMK key
		        kms_key_id = aws_kms_key.example_kms_key.arn

			  tags = {
			      Name = "database-1"
			        }
				}

# Create security group for RDS
				resource "aws_security_group" "example_db_sg" {
				  name_prefix = "example-db-sg"

