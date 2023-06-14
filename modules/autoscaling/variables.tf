variable "subnet_type" {
  default = {
    public  = "public"
    private = "private"
  }
}
variable "cidr_ranges" {
  default = {
    public1  = "172.16.1.0/24"
    public2  = "172.16.3.0/24"
    private1 = "172.16.4.0/24"
    private2 = "172.16.5.0/24"
  }
}

variable "terraform_name_prefix" {
  type    = string
  default = "terraform"
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "amazon_linux_image" {
  type    = string
  default = "ami-0e23c576dacf2e3df"
}

variable "autoscaling_adjustment_type" {
  type    = string
  default = "ChangeInCapacity"
}

variable "autoscaling_policy_name" {
  type    = string
  default = "autoscaling_policy"
}

variable "cloudwatch_cpu_alarm_name" {
  type    = string
  default = "cpu_usage_alarm"
}

variable "cloudwatch_cpu_comparison_operator" {
  type    = string
  default = "GreaterThanOrEqualToThreshold"
}

variable "cloudwatch_cpu_alarm_metric" {
  type    = string
  default = "CPUUtilization"
}

variable "cloudwatch_cpu_alarm_namespace" {
  type    = string
  default = "AWS/EC2"
}

variable "cloudwatch_cpu_monitoring_statistic" {
  type    = string
  default = "Average"
}

variable "ec2_load_balancer_name" {
  type    = string
  default = "ec2-load-balancer"
}

variable "ec2_load_balancer_type" {
  type    = string
  default = "application"
}

variable "ec2_load_balancer_traffic_type" {
  type    = string
  default = "HTTP"
}

variable "listener_type" {
  type    = string
  default = "forward"
}

variable "vpc_cidr_block" {
  type    = string
  default = "172.16.0.0/16"
}

variable "allow_all_traffic_cidr_block" {
  type    = string
  default = "0.0.0.0/0"
}

variable "availability_zones" {
  default = {
    zone_1 = "eu-west-1a"
    zone_2 = "eu-west-1b"
  }
}



