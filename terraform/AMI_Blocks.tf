# -----------------------------
# Get latest Private Server AMI
# -----------------------------
data "aws_ami" "private_server_ami" {
  most_recent = true
  name_regex  = "private-server-ami-*"
  owners      = ["self"]
}

# -----------------------------
# Get latest VPN-EC2 AMI
# -----------------------------
data "aws_ami" "vpn_ami" {
  most_recent = true
  name_regex  = "vpn-ami-*"
  owners      = ["self"]
}


# -----------------------------
# Get latest Nat-EC2 AMI
# -----------------------------
data "aws_ami" "nat_ami" {
  most_recent = true
  name_regex  = "nat-ami-*"
  owners      = ["self"]
}
