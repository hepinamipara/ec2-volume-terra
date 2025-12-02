provider "aws" {
  region = var.region
}

resource "aws_instance" "example" {
  ami                     = var.ami
  instance_type           = "t2.micro"
  disable_api_termination = true
  availability_zone       = var.region
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = var.security_group_ids
  ebs_optimized           = true
  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = "ubuntu-terraform-example"
  }
}

# ---- Extra Volumes (no device_name required) ----

resource "aws_ebs_volume" "vol1" {
  availability_zone = aws_instance.example.availability_zone
  size              = var.volume1_size
  type              = "gp3"
}

resource "aws_ebs_volume" "vol2" {
  availability_zone = aws_instance.example.availability_zone
  size              = var.volume2_size
  type              = "gp3"
}

resource "aws_ebs_volume" "vol3" {
  availability_zone = aws_instance.example.availability_zone
  size              = var.volume3_size
  type              = "gp3"
}

# ---- Attach Volumes (device_name = auto) ----

resource "aws_volume_attachment" "att1" {
  volume_id   = aws_ebs_volume.vol1.id
  instance_id = aws_instance.example.id
  device_name = ""
}

resource "aws_volume_attachment" "att2" {
  volume_id   = aws_ebs_volume.vol2.id
  instance_id = aws_instance.example.id
  device_name = ""
}

resource "aws_volume_attachment" "att3" {
  volume_id   = aws_ebs_volume.vol3.id
  instance_id = aws_instance.example.id
  device_name = ""
}
