# main.tf - Architecture simple : 3 instances (front, back, db)

terraform {
    required_version = ">= 1.0"
    
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

locals {
    timestamp = formatdate("MMdd-hhmm", timestamp())
}

# ===========================================
# DATA SOURCES
# ===========================================

# AMI Ubuntu 22.04
data "aws_ami" "ubuntu" {
    most_recent = true
    owners      = ["099720109477"]

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
}

# ===========================================
# RÉSEAU SIMPLE
# ===========================================

# VPC par défaut (plus simple)
resource "aws_default_vpc" "default" {
    tags = {
        Name = "${var.project_name}-vpc"
    }
}

# ===========================================
# SÉCURITÉ
# ===========================================

# Clé SSH
resource "aws_key_pair" "main" {
    key_name   = "devops-todouxlist-key-${local.timestamp}"
    public_key = file(var.ssh_public_key_path)
}

# Security Group Frontend
resource "aws_security_group" "frontend" {
    name        = "devops-todouxlist-frontend-sg-${local.timestamp}"
    description = "Security group pour Frontend"

    # SSH
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = var.allowed_ssh_ips
    }

    # HTTP
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # HTTPS
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-frontend-sg"
    }
}

# Security Group Backend
resource "aws_security_group" "backend" {
    name        = "devops-todouxlist-backend-sg-${local.timestamp}"
    description = "Security group pour Backend"

    # SSH
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = var.allowed_ssh_ips
    }

    # API (port 3000 pour NestJS)
    ingress {
        from_port   = 3000
        to_port     = 3000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Ou restreindre au frontend
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-backend-sg"
    }
}

# Security Group Database
resource "aws_security_group" "database" {
    name        = "devops-todouxlist-database-sg-${local.timestamp}"
    description = "Security group pour Database"

    # SSH
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = var.allowed_ssh_ips
    }

    # MySQL depuis le backend
    ingress {
        from_port       = 3306
        to_port         = 3306
        protocol        = "tcp"
        security_groups = [aws_security_group.backend.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-database-sg"
    }
}

# ===========================================
# INSTANCES EC2
# ===========================================

# Frontend (React)
resource "aws_instance" "frontend" {
    ami                    = data.aws_ami.ubuntu.id
    instance_type          = "t2.micro"  # Free Tier!
    key_name               = aws_key_pair.main.key_name
    vpc_security_group_ids = [aws_security_group.frontend.id]

    user_data = <<-EOF
        #!/bin/bash
        apt-get update
        apt-get install -y nginx nodejs npm
        
        # Configuration nginx pour React
        cat > /etc/nginx/sites-available/default << 'NGINX'
        server {
            listen 80;
            root /var/www/html;
            index index.html;
            
            location / {
                try_files \$uri \$uri/ /index.html;
            }
            
            location /api {
                proxy_pass http://${aws_instance.backend.private_ip}:3000;
                proxy_http_version 1.1;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host \$host;
                proxy_cache_bypass \$http_upgrade;
            }
        }
        NGINX
        
        systemctl restart nginx
    EOF

    tags = {
        Name = "${var.project_name}-frontend"
        Type = "frontend"
    }
}

# Backend (NestJS)
resource "aws_instance" "backend" {
    ami                    = data.aws_ami.ubuntu.id
    instance_type          = "t2.micro"  # Free Tier!
    key_name               = aws_key_pair.main.key_name
    vpc_security_group_ids = [aws_security_group.backend.id]

    user_data = <<-EOF
        #!/bin/bash
        apt-get update
        apt-get install -y nodejs npm
        
        # Install PM2 pour gérer Node.js
        npm install -g pm2
        
        # Créer le dossier pour l'app
        mkdir -p /var/www/backend
    EOF

    tags = {
        Name = "${var.project_name}-backend"
        Type = "backend"
    }
}

# Database (MySQL)
resource "aws_instance" "database" {
    ami                    = data.aws_ami.ubuntu.id
    instance_type          = "t2.micro"  # Free Tier!
    key_name               = aws_key_pair.main.key_name
    vpc_security_group_ids = [aws_security_group.database.id]

    user_data = <<-EOF
        #!/bin/bash
        apt-get update
        apt-get install -y mysql-server

        # Configuration MySQL
        sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

        systemctl restart mysql

        # Créer la base et l'utilisateur
        mysql << MYSQL
        CREATE DATABASE ${var.db_name};
        CREATE USER '${var.db_user}'@'%' IDENTIFIED BY '${var.db_password}';
        GRANT ALL PRIVILEGES ON ${var.db_name}.* TO '${var.db_user}'@'%';
        FLUSH PRIVILEGES;
        MYSQL
    EOF

    tags = {
        Name = "${var.project_name}-database"
        Type = "database"
    }
}

# ===========================================
# OUTPUTS
# ===========================================

output "frontend_public_ip" {
    value = aws_instance.frontend.public_ip
}

output "backend_public_ip" {
    value = aws_instance.backend.public_ip
}

output "backend_private_ip" {
    value = aws_instance.backend.private_ip
}

output "database_public_ip" {
    value = aws_instance.database.public_ip
}

output "database_private_ip" {
    value = aws_instance.database.private_ip
}

output "app_url" {
    value = "http://${aws_instance.frontend.public_ip}"
}

output "api_url" {
    value = "http://${aws_instance.backend.public_ip}:3000"
}

output "ssh_commands" {
    value = {
        frontend = "ssh ubuntu@${aws_instance.frontend.public_ip}"
        backend  = "ssh ubuntu@${aws_instance.backend.public_ip}"
        database = "ssh ubuntu@${aws_instance.database.public_ip}"
    }
}