# Output definitions for the Sentinel module

output "sentinel_public_ip" {
  description = "The public IP address of the deployed Sentinel node."
  value       = aws_instance.sentinel.public_ip
}

output "sentinel_instance_id" {
  description = "The ID of the deployed Sentinel EC2 instance."
  value       = aws_instance.sentinel.id
}
