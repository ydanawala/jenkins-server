provider "aws" {
  region = "us-east-1" 
}

resource "aws_security_group" "jenkins-server-sg" {
  name        = "jenkins-server-sg"
  description = "Security group for the jenkins server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "Jenkins-server" {
  ami           = "ami-0c7217cdde317cfec" 
  instance_type = "t2.micro"              
  security_groups = [aws_security_group.jenkins-server-sg.name]
  
 user_data = <<-EOF
    #!/bin/bash

    # Update package repositories
    sudo yum update -y

    # Install Java (required for Jenkins)
    sudo yum install -y java-1.8.0-openjdk

    # Add Jenkins repository and install Jenkins
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    sudo yum install -y jenkins

    # Start Jenkins service
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
  EOF

  tags = {
    Name = "Jenkins-server"  
  }
  metadata_options {
    http_tokens = "required"
  }
}


