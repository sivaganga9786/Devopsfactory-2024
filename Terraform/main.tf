
# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MainVPC1"
  }
}

# Create a Subnet
resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "MainSubnet1"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "MainIGW1"
  }
}

# Create a Route Table
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "MainRouteTable1"
  }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "main_subnet_association" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

# Create a Security Group
resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere (Update as needed)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MainSG1"
  }
}

# Create the EC2 Instance

resource "aws_instance" "terraform_auto1" {
  ami           = "ami-0ae8f15ae66fe8cda"  # Your AMI ID
  instance_type = "t2.micro"               # Instance type
  subnet_id     = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.main_sg.id]  # Use vpc_security_group_ids instead of security_groups
  user_data = <<-EOF
        #!/bin/bash

        # Check if Ansible is installed
        if command -v ansible >/dev/null 2>&1; then
            echo "Ansible is already installed."
            ansible --version
        else
            echo "Ansible is not installed. Installing Ansible..."

            # Detect OS and install Ansible accordingly
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                OS=$ID
            else
                echo "Unsupported OS. Please install Ansible manually."
                exit 1
            fi

            case "$OS" in
                ubuntu|debian)
                    sudo apt-get update
                    sudo apt-get install -y ansible
                    ;;
                centos|rhel|fedora|rocky|almalinux)
                    sudo yum install -y epel-release
                    sudo yum install -y ansible
                    ;;
                amzn)
                    # Check for amazon-linux-extras, else use pip
                    if command -v amazon-linux-extras >/dev/null 2>&1; then
                        sudo amazon-linux-extras install ansible2 -y
                    else
                        sudo yum install -y python3 python3-pip
                        sudo pip3 install ansible
                    fi
                    ;;
                *)
                    echo "Unsupported OS: $OS. Please install Ansible manually."
                    exit 1
                    ;;
            esac

            # Verify installation
            if command -v ansible >/dev/null 2>&1; then
                echo "Ansible installation successful."
                ansible --version
            else
                echo "Ansible installation failed."
                exit 1
            fi
        fi
  EOF
  tags = {
    Name = "ansible-ec2"
  }

  key_name = "mykeypair2024"  # Replace with your key pair name
}