# Variable definitions for the Nomad module

variable "aws_region" {
  description = "The AWS region to deploy the Nomad node in."
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The EC2 instance type for the Nomad node."
  type        = string
  # Default to a smaller instance size for cost-effective scaling
  default     = "t3.small"
}

variable "ami_id" {
  description = "The ID of the AMI to use (e.g., an Ubuntu 20.04 AMI)."
  type        = string
  # A common Ubuntu 20.04 AMI for us-east-1, will need to be updated for other regions.
  default     = "ami-0c55b159cbfafe1f0"
}

variable "node_count" {
  description = "The number of Nomad nodes to deploy."
  type        = number
  default     = 1
}
