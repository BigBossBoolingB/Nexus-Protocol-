# main.tf for the root module

# This file demonstrates how to use the `sentinel` module.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  # In a real scenario, credentials would be configured via environment variables
  # or other secure means, not hardcoded here.
}

# Instantiate our custom Sentinel module from the local path
module "nexus_sentinel_1" {
  source = "./modules/sentinel"

  # We can override the module's default variables here if needed.
  # For example:
  # instance_type = "t3.medium"
}

# Output the public IP address of the created Sentinel node,
# which is retrieved from the module's outputs.
output "sentinel_node_public_ip" {
  description = "Public IP of the deployed Nexus Sentinel node."
  value       = module.nexus_sentinel_1.sentinel_public_ip
}
