variable "cluster_names" {
  description = "user names list"
  default = [
    "user1",
    "user2"
  ]
}

variable "attach_policy_emr_role" {
  description = "iam policy list to attach emr role"
  default = [
    "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
  ]
}