variable "key_name" {
  description = "Name for AWS key pair"
  default     = "kube-cluster-key"
}

variable "public_key_path" {
  description = "Path to your SSH public key"
  default     = "~/.ssh/kube-cluster.pub"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.medium"
}