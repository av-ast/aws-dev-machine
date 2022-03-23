locals {
  user = "ec2-user"
}

resource "tls_private_key" "machine" {
  algorithm = "RSA"
}

resource "local_file" "private_key" {
  content         = tls_private_key.machine.private_key_pem
  filename        = var.ssh_pem_file
  file_permission = "0600"
}

resource "aws_key_pair" "machine" {
  key_name   = var.project
  public_key = tls_private_key.machine.public_key_openssh
  tags = {
    Name = "Dev machine key pair"
  }
}

resource "aws_network_interface" "machine" {
  subnet_id         = var.subnet_id
  source_dest_check = false
  security_groups = [
    var.security_groups.ssh
  ]
}

resource "aws_instance" "machine" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.machine.key_name

  network_interface {
    network_interface_id = aws_network_interface.machine.id
    device_index         = 0
  }

  tags = {
    Name = var.project
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.instance_volume_size
    delete_on_termination = true
  }
}

resource "null_resource" "machine_bootstrap" {
  triggers = {
    id = aws_instance.machine.id
  }

  connection {
    type        = "ssh"
    host        = aws_instance.machine.public_ip
    user        = local.user
    port        = "22"
    private_key = tls_private_key.machine.private_key_pem
    agent       = false
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker tmux",
      "pip3 install docker-compose",
      "sudo usermod -aG docker ${local.user}",
      "sudo systemctl enable docker",
      "sudo systemctl start docker"
      # "curl -O ${var.openvpn_install_script_location}",
      # "chmod +x openvpn-install.sh",
      # <<EOT
      # sudo AUTO_INSTALL=y \
      #      APPROVE_IP=${aws_eip.openvpn_eip.public_ip} \
      #      ENDPOINT=${var.vpn_domain} \
      #      ./openvpn-install.sh
      # EOT
      ,
    ]
  }
}

