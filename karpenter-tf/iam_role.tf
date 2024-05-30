resource "aws_iam_role" "controller_role" {
  name = "${var.appname}_controller_eks_role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${var.oidc_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${var.oidc_url}:aud": "sts.amazonaws.com",
          "${var.oidc_url}:sub": "system:serviceaccount:${var.namespace}:${var.serviceaccount}"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::440948357464:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "access_policy" {
  name = "${var.appname}_policy"
  description = "${var.appname}_eks_role  access policy"
  depends_on = [
    aws_iam_role.controller_role]
  policy = jsonencode(
    {
      "Statement": [
        {
          "Action": [
            "ssm:GetParameter",
            "ec2:DescribeImages",
            "ec2:RunInstances",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeLaunchTemplates",
            "ec2:DescribeInstances",
            "ec2:DescribeInstanceTypes",
            "ec2:DescribeInstanceTypeOfferings",
            "ec2:DescribeAvailabilityZones",
            "ec2:DeleteLaunchTemplate",
            "ec2:CreateTags",
            "ec2:CreateLaunchTemplate",
            "ec2:CreateFleet",
            "ec2:DescribeSpotPriceHistory",
            "pricing:GetProducts"
          ],
          "Effect": "Allow",
          "Resource": "*",
          "Sid": "Karpenter"
        },
        {
          "Action": "ec2:TerminateInstances",
          "Condition": {
            "StringLike": {
              "ec2:ResourceTag/karpenter.sh/nodepool": "*"
            }
          },
          "Effect": "Allow",
          "Resource": "*",
          "Sid": "ConditionalEC2Termination"
        },
        {
          "Effect": "Allow",
          "Action": "iam:PassRole",
          "Resource": "arn:aws:iam::440948357464:role/${var.appname}_eks_role",
          "Sid": "PassNodeIAMRole"
        },
        {
          "Effect": "Allow",
          "Action": "eks:DescribeCluster",
          "Resource": "arn:aws:eks:ap-southeast-1:440948357464:cluster/${var.env}_cluster",
          "Sid": "EKSClusterEndpointLookup"
        },
        {
          "Sid": "AllowScopedInstanceProfileCreationActions",
          "Effect": "Allow",
          "Resource": "*",
          "Action": [
            "iam:CreateInstanceProfile"
          ],
          "Condition": {
            "StringEquals": {
              "aws:RequestTag/kubernetes.io/cluster/${var.env}_cluster": "owned",
              "aws:RequestTag/topology.kubernetes.io/region": "ap-southeast-1"
            },
            "StringLike": {
              "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
            }
          }
        },
        {
          "Sid": "AllowScopedInstanceProfileTagActions",
          "Effect": "Allow",
          "Resource": "*",
          "Action": [
            "iam:TagInstanceProfile"
          ],
          "Condition": {
            "StringEquals": {
              "aws:ResourceTag/kubernetes.io/cluster/${var.env}_cluster": "owned",
              "aws:ResourceTag/topology.kubernetes.io/region": "ap-southeast-1",
              "aws:RequestTag/kubernetes.io/cluster/${var.env}_cluster": "owned",
              "aws:RequestTag/topology.kubernetes.io/region": "ap-southeast-1"
            },
            "StringLike": {
              "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*",
              "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
            }
          }
        },
        {
          "Sid": "AllowScopedInstanceProfileActions",
          "Effect": "Allow",
          "Resource": "*",
          "Action": [
            "iam:AddRoleToInstanceProfile",
            "iam:RemoveRoleFromInstanceProfile",
            "iam:DeleteInstanceProfile"
          ],
          "Condition": {
            "StringEquals": {
              "aws:ResourceTag/kubernetes.io/cluster/${var.env}_cluster": "owned",
              "aws:ResourceTag/topology.kubernetes.io/region": "ap-southeast-1"
            },
            "StringLike": {
              "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*"
            }
          }
        },
        {
          "Sid": "AllowInstanceProfileReadActions",
          "Effect": "Allow",
          "Resource": "*",
          "Action": "iam:GetInstanceProfile"
        }
      ],
      "Version": "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "iam_role_attachment" {
  role = aws_iam_role.controller_role.name
  policy_arn = aws_iam_policy.access_policy.arn
  depends_on = [aws_iam_role.controller_role]
}

resource "aws_iam_role" "node_role" {
  name = "${var.appname}_node_eks_role"
  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

locals {
  roles = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

resource "aws_iam_role_policy_attachment" "node_iam_role_attachment" {
  count = length(local.roles)
  role = aws_iam_role.node_role.name
  policy_arn = local.roles[count.index]
  depends_on = [aws_iam_role.node_role]
}