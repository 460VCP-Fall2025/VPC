# -----------------------------
# Get latest Ubuntu AMI
# -----------------------------
data "aws_ami" "private_server_ami" {
  most_recent = true
  name_regex  = "private-server-ami-*"
  owners      = ["self"]
}

# -----------------------------
# Get latest Ubuntu AMI
# -----------------------------
data "aws_ami" "vpn_ami" {
  most_recent = true
  name_regex  = "private-vpn-ami-*"
  owners      = ["self"]
}


/*
# -----------------------------
# Get latest Ubuntu AMI
# -----------------------------
data "aws_ami" "nat_ami" {
  most_recent = true
  name_regex = "private-nat-ami-*"
  owners = ["self"]
}
*/