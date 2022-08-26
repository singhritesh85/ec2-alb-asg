resource "aws_security_group" "allow_http_ssh" {
  name        = var.security_group_name
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = "vpc-0582c689110087755"

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
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
    Name = "allow_tls"
  }
}

resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [ aws_security_group.allow_http_ssh.id ]  
  subnet_id = "subnet-0d75e47db9b4102f6"  

  user_data = <<-EOF
    #!/bin/bash
    yum install -y httpd
    service httpd start
    chkconfig httpd on
    echo "HelloWorld!!!" >> /var/www/html/index.html
  EOF

  tags = {
    Name = var.name
    Org  = var.orgname
  }
}

resource "aws_eip" "lb" {
  instance = aws_instance.web.id
  vpc      = true
}
