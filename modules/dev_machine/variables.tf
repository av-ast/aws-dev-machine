variable "project" {
  description = "Project name"
}

variable "subnet_id" {
  description = "Public subnet for dev machine"
}

variable "instance_type" {
  description = "Dev machine instance type"
}

variable "instance_volume_size" {
  description = "Dev machine volume size"
}

variable "instance_ami" {
  description = "Instance AMI"
  type        = string
}

variable "security_groups" {
  description = "Security groups"
}

variable "ssh_pem_file" {
  description = "SSH-key for connection to dev machine"
}
