resource "aws_key_pair" "k8s_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "k8s_sg" {
  name   = "k8s_sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
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

resource "aws_instance" "master" {
  ami                    = "ami-053b0d53c279acc90"  # Ubuntu 22.04 LTS
  instance_type          = var.instance_type
  key_name               = aws_key_pair.k8s_key.key_name
  subnet_id              = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  tags = {
    Name = "k8s-master"
  }
}

resource "aws_instance" "worker" {
  count                  = 2
  ami                    = "ami-053b0d53c279acc90"   # Ubuntu 22.04 LTS
  instance_type          = var.instance_type
  key_name               = aws_key_pair.k8s_key.key_name
  subnet_id              = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  tags = {
    Name = "k8s-worker-${count.index + 1}"
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    master_ip  = aws_instance.master.public_ip
    worker_ips = [for w in aws_instance.worker : w.public_ip]
  })
  filename = "${path.module}/inventory/hosts.ini"
}