# 1. Configure the Provider
provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "existing" {
  id = "vpc-0f8a17e37ce1b3964" # Replace with your actual VPC ID
}

# 3. Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = data.aws_vpc.existing.id
  tags = { Name = "main-igw" }
}

# 4. Create a Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = data.aws_vpc.existing.id
  cidr_block              = "10.0.1.0/24"
  tags = { Name = "public-subnet" }
}




# 7. Create Security Group for EC2
resource "aws_security_group" "allow_ssh" {
  name   = "allow_ssh"
  vpc_id = data.aws_vpc.existing.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Change to your IP for better security
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 8. Create EC2 Instance
resource "aws_instance" "web" {
  ami           = "ami-0c7217cdde317cfec" # Amazon Linux 2023 AMI (us-east-1)
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = { Name = "web-server" }
}
