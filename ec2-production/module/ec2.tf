resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  associate_public_ip_address = true
  ebs_optimized = true
  monitoring = true
  vpc_security_group_ids = ["sg-0c0568d77c6279a60", "sg-0a5e1ca5e56bd4e71"]
  subnet_id = "subnet-0d75e47db9b4102f6"
  key_name = "testkey"
  root_block_device {
    delete_on_termination = true
    encrypted = true
    kms_key_id = "d18afcd2-e019-4d43-a2ac-b77e11515613"
    volume_size = 20
    volume_type = "gp2"
    tags = {
      Name = var.name
      Environment = var.env
    }
  }
  user_data = <<-EOT
    #!/bin/bash
    /usr/sbin/useradd -s /bin/bash -m ritesh;
    mkdir /home/ritesh/.ssh;
    chmod -R 700 /home/ritesh;
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDB505AFZTdRbtHcT3PT2mEbTY/ppekzIoob5fawyCiaPs+RXZhrl9lcIx4aKcueoADUN/3BUb1sS+xe27HoO1AoOIm/6owU7sou9K1Qr7rxgvRGI8/30mVC+tIKJjAgfusEMmD7XMgkzNCfJveyb944jKT6SVae/EmcadVUc65SFCvPNcsb+NFaeidJxr9d1ZsGrkl0wD7PLVSkdTJI3JAMP4ACs497LT7Vbv7ceMqEFzkUZQZAqoMHi9aUIVbcMySmHO7RNBk5Z8BSzx/f0kjJzp8X+JoGFXiTxRx8VQntr6WP72O794zb6dR33O2mclfeZ7lXHUFYgdLMWX2ukgO9utTkKOjpHQTGjcFvie1cgrli4ninzyMbE1z1zaWfpqy1JIJ0LPH6d7t+C2U3HABB6Ml5UL++MF/2muwESzr1CIxAXUd+x9Sv9Rqb8ahSSFTOGEshU/NoVCJLKVAiP+5YgIhyHLLMpwHcTG7wC5D/TABkhbMC7DLnMqsNWykU0c= ritesh@DESKTOP-02A84PF" >> /home/ritesh/.ssh/authorized_keys;
    chmod 600 /home/ritesh/.ssh/authorized_keys;
    chown ritesh:ritesh /home/ritesh/.ssh -R;
    echo "ritesh  ALL=(ALL)  NOPASSWD:ALL" > /etc/sudoers.d/ritesh;
    chmod 440 /etc/sudoers.d/ritesh;
  EOT

  tags = {
    Name = "${var.name}-${var.env}"
    Environment = var.env
  }
}
