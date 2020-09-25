//---------------------------------
// s3
//---------------------------------
resource "aws_s3_bucket" "lt_demo" {
  bucket = "ds-backend-lt-demo"
  acl    = "private"
  tags = {
    teams = "backend"
  }
}

//---------------------------------
// emr
//---------------------------------
locals {
  cluster_names = ["user1"]
}

resource "aws_emr_cluster" "cluster" {
  for_each      = toset(local.cluster_names)
  name          = each.value
  release_label = "emr-5.30.1"
  applications  = ["Spark"]

  ec2_attributes {
    subnet_id                         = aws_subnet.emr_subnet.id
    emr_managed_master_security_group = aws_security_group.emr_sg.id
    emr_managed_slave_security_group  = aws_security_group.emr_sg.id
    instance_profile                  = aws_iam_instance_profile.emr_profile.arn
  }

  master_instance_group {
    instance_type = "m5.xlarge"
  }

  core_instance_group {
    instance_type  = "m5.xlarge"
    instance_count = 1
  }

  tags = {
    teams = "backend"
    user  = each.value
  }
  service_role = aws_iam_role.iam_emr_service_role.arn
}

//---------------------------------
// vpc
//---------------------------------
resource "aws_vpc" "lt_demo" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name  = "lt_demo"
    teams = "backend"
  }
}
resource "aws_subnet" "emr_subnet" {
  vpc_id     = aws_vpc.lt_demo.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name  = "emr_subnet"
    teams = "backend"
  }
}
//---------------------------------
// security group
//---------------------------------
resource "aws_security_group" "emr_sg" {
  name        = "emr_sg"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.lt_demo.id

  ingress {
    description = "allow all trafic"
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

  tags = {
    Name  = "emr_sg"
    teams = "backend"
  }
}
//---------------------------------
// iam
//---------------------------------
data "aws_iam_policy_document" "emr_s3_fullaccess" {
  statement {
    actions   = ["emr:*"]
    resources = ["arn:aws:emr:::*"]
  }
  statement {
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::*"]
  }
}

resource "aws_iam_role" "iam_emr_service_role" {
  name               = "iam_emr_service_role"
  assume_role_policy = data.aws_iam_policy_document.emr_s3_fullaccess.json
  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "emr_profile" {
  name = "emr_profile"
}