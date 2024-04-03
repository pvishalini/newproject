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
#create alb
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.webSg.id]
  subnets         = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "web"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}
 13 changes: 13 additions & 0 deletions13  
day-24/provider.tf
@@ -0,0 +1,13 @@
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.11.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}
