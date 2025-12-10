provider "aws" {
  region = var.region
}

resource "aws_instance" "example" {
  ami                     = var.ami
  instance_type           = "t2.micro"
  disable_api_termination = true
  availability_zone       = var.availability_zone
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = var.security_group_ids
  ebs_optimized           = true
  key_name                = var.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    iops        = 3000
    encrypted   = false
  }

  tags = {
    Name = "ubuntu-terraform-example"
  }
}

# ---- Extra Volumes ----

resource "aws_ebs_volume" "vol1" {
  availability_zone = aws_instance.example.availability_zone
  size              = var.volume1_size
  type              = "gp3"
  iops              = 3000
  encrypted         = false
}

resource "aws_ebs_volume" "vol2" {
  availability_zone = aws_instance.example.availability_zone
  size              = var.volume2_size
  type              = "gp3"
  iops              = 3000
  encrypted         = false
}

resource "aws_ebs_volume" "vol3" {
  availability_zone = aws_instance.example.availability_zone
  size              = var.volume3_size
  type              = "gp3"
  iops              = 3000
  encrypted         = false
}

# ---- Attach Volumes with valid device names ----

resource "aws_volume_attachment" "att1" {
  volume_id   = aws_ebs_volume.vol1.id
  instance_id = aws_instance.example.id
  device_name = "/dev/sdf"
}

resource "aws_volume_attachment" "att2" {
  volume_id   = aws_ebs_volume.vol2.id
  instance_id = aws_instance.example.id
  device_name = "/dev/sdg"
}

resource "aws_volume_attachment" "att3" {
  volume_id   = aws_ebs_volume.vol3.id
  instance_id = aws_instance.example.id
  device_name = "/dev/sdh"
}
