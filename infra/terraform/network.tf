resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-${var.environment}-private"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress = []
  egress  = []

  tags = {
    Name = "${var.project_name}-${var.environment}-default-sg"
  }
}

resource "aws_network_interface" "app" {
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.app.id]

  tags = {
    Name = "${var.project_name}-${var.environment}-app-eni"
  }
}
