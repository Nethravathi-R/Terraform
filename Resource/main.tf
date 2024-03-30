provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "k8s_cluster_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "K8s-cluster-vpc"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

resource "aws_subnet" "k8s_cluster_subnet" {
  vpc_id            = aws_vpc.k8s_cluster_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "K8s-cluster-net"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

resource "aws_internet_gateway" "k8s_cluster_igw" {
  vpc_id = aws_vpc.k8s_cluster_vpc.id

  tags = {
    Name = "k8s-cluster-igw"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

resource "aws_route_table" "k8s_cluster_rtb" {
  vpc_id = aws_vpc.k8s_cluster_vpc.id

  tags = {
    Name = "K8s-cluster-rtb"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_route_table.k8s_cluster_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.k8s_cluster_igw.id
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.k8s_cluster_subnet.id
  route_table_id = aws_route_table.k8s_cluster_rtb.id
}

data "aws_iam_policy_document" "master_policy" {
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVolumes",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyVolume",
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteVolume",
      "ec2:DetachVolume",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DescribeVpcs",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:AttachLoadBalancerToSubnets",
      "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateLoadBalancerPolicy",
      "elasticloadbalancing:CreateLoadBalancerListeners",
      "elasticloadbalancing:ConfigureHealthCheck",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteLoadBalancerListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DetachLoadBalancerFromSubnets",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancerPolicies",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
      "iam:CreateServiceLinkedRole",
      "kms:DescribeKey"
    ]

    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "master_policy" {
  name        = "k8s-cluster-iam-master-policy"
  policy      = data.aws_iam_policy_document.master_policy.json
}


resource "aws_iam_role" "master_role" {
  name               = "k8s-cluster-iam-master-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "k8s_master_profile" {
  name = "k8s-cluster-iam-master-profile"
  role = aws_iam_role.master_role.name
}

resource "aws_iam_role_policy_attachment" "master_policy_attachment" {
  role       = aws_iam_role.master_role.name
  policy_arn = aws_iam_policy.master_policy.arn
}


data "aws_iam_policy_document" "worker_policy" {
  statement {
    actions   = [
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:BatchGetImage",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "worker_policy" {
  name   = "k8s-cluster-iam-worker-policy"
  policy = data.aws_iam_policy_document.worker_policy.json
}

resource "aws_iam_role" "worker_role" {
  name               = "k8s-cluster-iam-worker-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "worker_instance_profile" {
  name = "k8s-cluster-worker-instance-profile"
  role = aws_iam_role.worker_role.name
}

resource "aws_iam_role_policy_attachment" "worker_policy_attachment" {
  role       = aws_iam_role.worker_role.name
  policy_arn = aws_iam_policy.worker_policy.arn
}


resource "aws_security_group" "k8s_master_sg" {
  name        = "k8s-master-sg"
  description = "Security group for Kubernetes master node"

  vpc_id = aws_vpc.k8s_cluster_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  
  }
}

resource "aws_instance" "k8s_master-node" {
  ami           = "ami-007020fd9c84e18c7"  
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.k8s_cluster_subnet.id
  iam_instance_profile = aws_iam_instance_profile.k8s_master_profile.name

  tags = {
    Name                                = "Master"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }

  security_groups = [aws_security_group.k8s_master_sg.id]
}

resource "aws_security_group" "k8s_worker_sg" {
  name        = "k8s-worker-sg"
  description = "Security group for Kubernetes worker node"

  vpc_id = aws_vpc.k8s_cluster_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k8s_worker" {
  ami           = "ami-007020fd9c84e18c7"  
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.k8s_cluster_subnet.id
  iam_instance_profile = aws_iam_instance_profile.worker_instance_profile.name

  tags = {
    Name                                = "Worker"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }

  security_groups = [aws_security_group.k8s_worker_sg.id]
}
