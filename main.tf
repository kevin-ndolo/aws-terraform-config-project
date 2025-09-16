# ─────────────────────────────────────────────────────────────
# VPC Setup: Defines the network boundary for all resources
# ─────────────────────────────────────────────────────────────
resource "aws_vpc" "kevin_test_1000_vpc" {
  cidr_block = var.cidr  # VPC CIDR block passed via variable
}

# ─────────────────────────────────────────────────────────────
# Subnets: Two public subnets in different AZs for HA
# ─────────────────────────────────────────────────────────────
resource "aws_subnet" "kevin_test_1000_sub1" {
  vpc_id                  = aws_vpc.kevin_test_1000_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true  # Ensures EC2 gets public IP
}

resource "aws_subnet" "kevin_test_1000_sub2" {
  vpc_id                  = aws_vpc.kevin_test_1000_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = true
}

# ─────────────────────────────────────────────────────────────
# Internet Gateway: Enables outbound internet access
# ─────────────────────────────────────────────────────────────
resource "aws_internet_gateway" "kevin_test_1000_igw" {
  vpc_id = aws_vpc.kevin_test_1000_vpc.id
}

# ─────────────────────────────────────────────────────────────
# Route Table: Routes traffic to the internet via IGW
# ─────────────────────────────────────────────────────────────
resource "aws_route_table" "kevin_test_1000_rt" {
  vpc_id = aws_vpc.kevin_test_1000_vpc.id

  route {
    cidr_block = "0.0.0.0/0"  # Default route for all outbound traffic
    gateway_id = aws_internet_gateway.kevin_test_1000_igw.id
  }
}

# ─────────────────────────────────────────────────────────────
# Route Table Associations: Attach route table to subnets
# ─────────────────────────────────────────────────────────────
resource "aws_route_table_association" "kevin_test_1000_rta1" {
  subnet_id      = aws_subnet.kevin_test_1000_sub1.id
  route_table_id = aws_route_table.kevin_test_1000_rt.id
}

resource "aws_route_table_association" "kevin_test_1000_rta2" {
  subnet_id      = aws_subnet.kevin_test_1000_sub2.id
  route_table_id = aws_route_table.kevin_test_1000_rt.id
}

# ─────────────────────────────────────────────────────────────
# Security Group: Allows HTTP and SSH access
# ─────────────────────────────────────────────────────────────
resource "aws_security_group" "kevin_test_1000_webSg" {
  name   = "kevin_test_1000_websg"
  vpc_id = aws_vpc.kevin_test_1000_vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All outbound traffic allowed
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kevin_test_1000_Web-sg"
  }
}

# ─────────────────────────────────────────────────────────────
# S3 Bucket: Stores static assets for EC2 to fetch
# ─────────────────────────────────────────────────────────────
resource "aws_s3_bucket" "example" {
  bucket = "kevin-test-1000-aws-terraform-config-project-s3-bucket"
}

# ─────────────────────────────────────────────────────────────
# EC2 Instances: Two web servers in separate subnets
# ─────────────────────────────────────────────────────────────
resource "aws_instance" "kevin_test_1000_webserver1" {
  ami                    = "ami-0a716d3f3b16d290c"  # Ubuntu 24.04 LTS
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.kevin_test_1000_webSg.id]
  subnet_id              = aws_subnet.kevin_test_1000_sub1.id
  user_data_base64       = base64encode(file("userdata.sh"))  # Boot script

  tags = {
    Name = "kevin_test_1000_webserver1"
  }
}

resource "aws_instance" "kevin_test_1000_webserver2" {
  ami                    = "ami-0a716d3f3b16d290c"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.kevin_test_1000_webSg.id]
  subnet_id              = aws_subnet.kevin_test_1000_sub2.id
  user_data_base64       = base64encode(file("userdata1.sh"))

  tags = {
    Name = "kevin_test_1000_webserver2"
  }
}

# ─────────────────────────────────────────────────────────────
# Application Load Balancer: Distributes traffic across EC2s
# ─────────────────────────────────────────────────────────────
resource "aws_lb" "kevin_test_1000_myalb" {
  name               = "kevin-test-1000-myalb"
  internal           = false  # Public-facing ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.kevin_test_1000_webSg.id]
  subnets            = [
    aws_subnet.kevin_test_1000_sub1.id,
    aws_subnet.kevin_test_1000_sub2.id
  ]

  tags = {
    Name = "kevin_test_1000_web"
  }
}

# ─────────────────────────────────────────────────────────────
# Target Group: Defines backend EC2s for ALB
# ─────────────────────────────────────────────────────────────
resource "aws_lb_target_group" "kevin_test_1000_tg" {
  name     = "kevin-test-1000-myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.kevin_test_1000_vpc.id

  health_check {
    path = "/"  # Basic health check path
    port = "traffic-port"
  }
}

# ─────────────────────────────────────────────────────────────
# Target Group Attachments: Register EC2s with ALB
# ─────────────────────────────────────────────────────────────
resource "aws_lb_target_group_attachment" "kevin_test_1000_attach1" {
  target_group_arn = aws_lb_target_group.kevin_test_1000_tg.arn
  target_id        = aws_instance.kevin_test_1000_webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "kevin_test_1000_attach2" {
  target_group_arn = aws_lb_target_group.kevin_test_1000_tg.arn
  target_id        = aws_instance.kevin_test_1000_webserver2.id
  port             = 80
}

# ─────────────────────────────────────────────────────────────
# Listener: Routes incoming traffic to target group
# ─────────────────────────────────────────────────────────────
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.kevin_test_1000_myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.kevin_test_1000_tg.arn
    type             = "forward"
  }
}

# ─────────────────────────────────────────────────────────────
# Output: Exposes ALB DNS for browser access
# ─────────────────────────────────────────────────────────────
output "loadbalancerdns" {
  value = aws_lb.kevin_test_1000_myalb.dns_name
}
