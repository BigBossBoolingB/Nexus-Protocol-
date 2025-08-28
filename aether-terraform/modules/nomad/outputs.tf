# Output definitions for the Nomad module

output "nomad_public_ips" {
  description = "A list of public IP addresses of the deployed Nomad nodes."
  value       = aws_instance.nomad.*.public_ip
}

output "nomad_instance_ids" {
  description = "A list of IDs of the deployed Nomad EC2 instances."
  value       = aws_instance.nomad.*.id
}
