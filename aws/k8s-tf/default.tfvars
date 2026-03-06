# AWS Settings
aws_region               = "us-east-2"
aws_cred_file            = "~/.aws/aws-terraform.json"
availability_zones_count = 2
creator_tag              = "mhaigh"
email                    = "m.haigh@veeam.com"

# VPC Settings
eks_vpc_cidr             = "10.30.0.0/16"
eks_public_subnet_cidrs  = ["10.30.0.0/24", "10.30.1.0/24"]   # len must equal availability_zones_count
eks_private_subnet_cidrs = ["10.30.10.0/24", "10.30.11.0/24"] # len must equal availability_zones_count

# EKS Settings
eks_kubernetes_version = "1.32"
eks_node_count         = 2
eks_node_min           = 2
eks_node_max           = 5
eks_node_volume_size   = 50
eks_instance_type      = "t2.medium"
eks_addons = [
  {
    name    = "kube-proxy"
    version = "v1.32.11-eksbuild.5"
  },
  #{
  #  name    = "vpc-cni"
  #  version = "v1.21.1-eksbuild.3"
  #},
  {
    name    = "coredns"
    version = "v1.11.4-eksbuild.28"
  },
  #{
  #  name    = "aws-ebs-csi-driver"
  #  version = "v1.56.0-eksbuild.1"
  #},
]

# Authorized Networks
authorized_networks = [
  {
    cidr_block   = "198.51.100.0/24"
    display_name = "company_range"
  },
  {
    cidr_block   = "203.0.113.30/32"
    display_name = "home_address"
  },
]

# Outputs
vscrd_release = "https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-5.0"
