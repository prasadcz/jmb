variable "env" {
  type = string
}

variable "oidc_url" {
  default = "oidc.eks.ap-south-1.amazonaws.com/id/5E56C3347148F75B3D6316BB14A335E1"
}

variable "oidc_arn" {
  default = "arn:aws:iam::552171489163:oidc-provider/oidc.eks.ap-south-1.amazonaws.com/id/5E56C3347148F75B3D6316BB14A335E1"
}

variable "namespace" {
  default = "kube-system"
}

variable "appname" {
  default = "karpenter"
}
variable "serviceaccount" {
  default = "karpenter"
}
