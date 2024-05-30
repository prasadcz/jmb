variable "env" {
  type = string
}

variable "oidc_url" {
  default = "oidc.eks.ap-southeast-1.amazonaws.com/id/9358F63536D222E420F63C3772459B6E"
}

variable "oidc_arn" {
  default = "arn:aws:iam::440948357464:oidc-provider/oidc.eks.ap-southeast-1.amazonaws.com/id/9358F63536D222E420F63C3772459B6E"
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