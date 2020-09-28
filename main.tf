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
resource "aws_emr_cluster" "cluster" {
  for_each      = toset(var.cluster_names)
  name          = each.value
  release_label = "emr-5.30.1"
  applications  = ["Spark"]

  ec2_attributes {
    subnet_id        = aws_subnet.emr_subnet.id
    instance_profile = aws_iam_instance_profile.emr_ec2_profile.name
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
  service_role = aws_iam_role.emr_service_role.arn
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
  vpc_id                  = aws_vpc.lt_demo.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name  = "emr_subnet"
    teams = "backend"
  }
}

//---------------------------------
// route table
//---------------------------------
resource "aws_route_table" "emr_route_table" {
  vpc_id = aws_vpc.lt_demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.emr_gw.id
  }

  tags = {
    Name = "lt-remo"
    tams = "backend"
  }
}

resource "aws_route_table_association" "emr_subnet_routing" {
  subnet_id      = aws_subnet.emr_subnet.id
  route_table_id = aws_route_table.emr_route_table.id
}

//---------------------------------
// internet_gateway
//---------------------------------
resource "aws_internet_gateway" "emr_gw" {
  vpc_id = aws_vpc.lt_demo.id

  tags = {
    Name  = "lt-demo"
    teams = "backend"
  }
}

//---------------------------------
// iam (EMR)
//---------------------------------
data "aws_iam_policy_document" "emr_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "emr_service_role" {
  name               = "LT_EMR_DefaultRole"
  assume_role_policy = data.aws_iam_policy_document.emr_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "emr_service_role" {
  for_each   = toset(var.attach_policy_emr_role)
  role       = aws_iam_role.emr_service_role.name
  policy_arn = each.value
}

//---------------------------------
// iam (EC2)
//---------------------------------
resource "aws_iam_role" "emr_ec2_role" {
  name               = "LT_EMR_EC2_DefaultRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}


data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "emr_ec2_role" {
  role       = aws_iam_role.emr_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_instance_profile" "emr_ec2_profile" {
  name = "emr-ec2-profile"
  role = aws_iam_role.emr_ec2_role.name
}