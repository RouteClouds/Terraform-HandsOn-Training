aws_region = "us-east-1"

instance_config = {
  instance_type = "t2.micro"
  environment   = "dev"
  count        = 2
  ami_id       = "ami-0c55b159cbfafe1f0"
}

allowed_ports = [80, 443, 22, 8080]

instance_tags = {
  Environment = "dev"
  Project     = "variable-types-lab"
  ManagedBy   = "terraform"
  Team        = "DevOps"
} 