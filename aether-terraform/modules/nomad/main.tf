# main.tf for the Nomad module

# Defines the security group (firewall) for the Nomad nodes.
resource "aws_security_group" "nomad_sg" {
  name        = "nomad-sg"
  description = "Allow P2P, RPC, and SSH traffic for Nexus Nomad"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: In production, this should be restricted.
  }

  ingress {
    description = "Nexus P2P"
    from_port   = 8787
    to_port     = 8787
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Nexus RPC"
    from_port   = 8788
    to_port     = 8788
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
    Name = "nexus-nomad-sg"
  }
}

# Defines the EC2 instances that will run the Nomad nodes.
# The `count` meta-argument allows us to create a swarm of nodes.
resource "aws_instance" "nomad" {
  count         = var.node_count
  ami           = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.nomad_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              set -e
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

              echo "--- Starting Nexus Nomad Bootstrap Script ---"

              FORGE_VERSION="latest"
              FORGE_ARCH="amd64"
              FORGE_REPO_URL="https://your-repository.com/forge-nexus"

              echo "Downloading Forge SDK..."
              wget -O /tmp/forge-nexus ${FORGE_REPO_URL}/${FORGE_VERSION}/forge-nexus-${FORGE_ARCH}
              wget -O /tmp/forge-nexus.sha256 ${FORGE_REPO_URL}/${FORGE_VERSION}/forge-nexus-${FORGE_ARCH}.sha256

              echo "Verifying Forge SDK..."
              (cd /tmp && sha256sum -c forge-nexus.sha256)

              echo "Installing Forge SDK..."
              chmod +x /tmp/forge-nexus
              mv /tmp/forge-nexus /usr/local/bin/forge-nexus

              echo "Installing Nomad Node software..."
              /usr/local/bin/forge-nexus install --role=nomad --version=latest

              echo "Starting Nomad Node service..."
              /usr/local/bin/forge-nexus start

              echo "--- Nexus Nomad Bootstrap Script Finished ---"
              EOF

  tags = {
    Name = "Nexus-Nomad-Node-${count.index + 1}"
  }
}
