# Topic 9 Lab: Terraform Import & State Manipulation
# outputs.tf - Output Values

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.lab.id
}

output "instance_public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.lab.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.lab.private_ip
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.lab.arn
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.lab.id
}

output "security_group_name" {
  description = "Security group name"
  value       = aws_security_group.lab.name
}

output "instance_state" {
  description = "Current state of the instance"
  value       = aws_instance.lab.instance_state
}

output "import_command" {
  description = "Command to import this instance"
  value       = "terraform import aws_instance.lab ${aws_instance.lab.id}"
}

output "state_commands" {
  description = "Useful state manipulation commands"
  value = {
    list_resources = "terraform state list"
    show_resource  = "terraform state show aws_instance.lab"
    remove_resource = "terraform state rm aws_instance.lab"
    move_resource  = "terraform state mv aws_instance.lab aws_instance.imported"
  }
}

