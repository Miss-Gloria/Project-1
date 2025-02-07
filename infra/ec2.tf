resource "aws_instance" "gloria_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet[0].id # Use Terraform resource
  vpc_security_group_ids = [aws_security_group.gloria_sg.id]
  key_name               = data.aws_ssm_parameter.key_name.value # This stays, as it's already in SSM

  user_data = file("${path.module}/nginx_script.sh")

  tags = {
    Name = "Gloria Server"
  }
}
