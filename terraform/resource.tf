resource "aws_vpc" "project-vpc" {
  cidr_block       = "10.0.0.0/16"
  
  tags = {
    Name = "vpc-project1"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.project-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "project1-pubSubnet"
  }
}

resource "aws_internet_gateway" "project-igw" {
  vpc_id = aws_vpc.project-vpc.id

  tags = {
    Name = "project1-IGW"
  }
}

resource "aws_route_table" "project-rt" {
  vpc_id = aws_vpc.project-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project-igw.id
  }
  tags = {
    Name = "MY-RT"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.project-rt.id
}

resource "aws_security_group" "project-Sg" {
  name        = "SG-Project1"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.project-vpc.id

  
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "SSH"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]  
  }
  
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "-tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SG-project1"
  }
}


resource "aws_instance" "project-instance" {
  ami           = "ami-05295b6e6c790593e"
  instance_type = "t2.micro"
  secuirty_groups = ["aws_security_group.project-Sg.id"]
   key_name   = "mumbai.pem"
   vpc_id     = aws_vpc.project-vpc.id
   subnet_id = aws_subnet.public-subnet.id
  tags = {
    Name = "MyprojectInstance"
  }
}
