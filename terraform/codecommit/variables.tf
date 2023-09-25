variable "ssh_key_basepath" {
  description = "path to .ssh directory"
  type = string
  # For AWS EC2 override with
  # export TF_VAR_ssh_key_basepath="/home/ec2-user/.ssh"
  default = "~/.ssh"
}