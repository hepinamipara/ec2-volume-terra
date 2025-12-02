variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "ami" {
  type        = string
  description = "Ubuntu Server 22.04 LTS-us-east-1" # Ubuntu Server 22.04 LTS (HVM),EBS General Purpose (SSD) Volume Type. Support available from Canonical
  default     = "ami-0c398cb65a93047f2"
}

variable "vpc_id" {
  type        = string
  description = "Your VPC ID (used for tagging / reference)"
  default     = ""
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where EC2 will be launched (required)"
  default     = ""

}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to attach to the instance"
  default     = []
}

variable "availability_zone" {
  type        = string
  description = "Availability Zone (used for extra EBS volumes' AZ)"
  default     = ""
}

variable "root_volume_size" {
  type        = number
  description = "Root volume size (GB)"
  default     = 10
}

variable "volume1_size" {
  type        = number
  description = "2"
  default     = 2
}

variable "volume2_size" {
  type        = number
  description = "3"
  default     = 3
}

variable "volume3_size" {
  type        = number
  description = "3"
  default     = 3
}
