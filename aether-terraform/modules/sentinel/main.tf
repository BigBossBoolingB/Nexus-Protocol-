# main.tf for the Sentinel module

# Defines the security group (firewall) for the Sentinel node.
resource "aws_security_group" "sentinel_sg" {
  name        = "sentinel-sg"
  description = "Allow P2P, RPC, and SSH traffic for Nexus Sentinel"

  # Allow SSH traffic for administration
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: In production, this should be restricted to specific IPs.
  }

  # Allow P2P traffic from any source
  ingress {
    description = "Nexus P2P"
    from_port   = 8787
    to_port     = 8787
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow RPC traffic from any source
  ingress {
    description = "Nexus RPC"
    from_port   = 8788
    to_port     = 8788
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nexus-sentinel-sg"
  }
}

# Defines the EC2 instance that will run the Sentinel node.
resource "aws_instance" "sentinel" {
  ami           = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.sentinel_sg.id]

  # This startup script automates the entire Sentinel node installation.
  user_data = <<-EOF
              #!/bin/bash
              set -e # Exit immediately if a command exits with a non-zero status.
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

              echo "--- Starting Nexus Sentinel Bootstrap Script ---"

              # Variables - these could be templatized from Terraform variables
              FORGE_VERSION="latest"
              FORGE_ARCH="amd64"
              # This would need to be a real URL
              FORGE_REPO_URL="https://your-repository.com/forge-nexus"

              # Step 1 & 2: Acquire and Verify The Forge SDK
              echo "Downloading Forge SDK..."
              wget -O /tmp/forge-nexus ${FORGE_REPO_URL}/${FORGE_VERSION}/forge-nexus-${FORGE_ARCH}
              wget -O /tmp/forge-nexus.sha256 ${FORGE_REPO_URL}/${FORGE_VERSION}/forge-nexus-${FORGE_ARCH}.sha256

              echo "Verifying Forge SDK..."
              (cd /tmp && sha256sum -c forge-nexus.sha256)

              # Step 3: Prepare The Forge
              echo "Installing Forge SDK..."
              chmod +x /tmp/forge-nexus
              mv /tmp/forge-nexus /usr/local/bin/forge-nexus

              # Step 4: Install the Sentinel Node
              echo "Installing Sentinel Node software..."
              # The SDK needs to be run with sudo if it writes to /etc or /usr
              /usr/local/bin/forge-nexus install --role=sentinel --version=latest

              # Step 5: Configure the Node (can be done manually later or automated)
              # For a fully automated setup, a pre-made config could be downloaded.
              # /usr/local/bin/forge-nexus configure

              # Step 6: Start the service
              echo "Starting Sentinel Node service..."
              /usr/local/bin/forge-nexus start

              echo "--- Nexus Sentinel Bootstrap Script Finished ---"
              EOF

  tags = {
    Name = "Nexus-Sentinel-Node"
  }
}
