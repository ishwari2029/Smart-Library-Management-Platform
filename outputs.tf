output "project_region" {
  description = "AWS region selected for Smart Library"
  value       = var.aws_region
}

output "project_name" {
  description = "Smart Library project name"
  value       = var.project_name
} 
output "ec2_public_ip" {
  description = "Public IP of Smart Library EC2 instance"
  value       = aws_instance.library_ec2.public_ip
}
