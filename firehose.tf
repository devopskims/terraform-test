resource "aws_s3_bucket" "bucket" {
  bucket = "alldata-tf"
}

resource "aws_kinesis_firehose_delivery_stream" "firehose" {
  name        = "firehose-terraform"
  destination = "elasticsearch"


  s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = aws_s3_bucket.bucket.arn
    buffer_size        = 10
    buffer_interval    = 400
    compression_format = "GZIP"
  }

  elasticsearch_configuration {
    domain_arn = aws_elasticsearch_domain.test_cluster.arn
    role_arn   = aws_iam_role.firehose_role.arn
    index_name = "test"
    type_name  = ""

    processing_configuration {
      enabled = "false"



      # processors {
      #   type = "Lambda"
      # }

    }
  }

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.datastream-terraform.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }


}

resource "aws_iam_role" "firehose_role" {
  name = "firehose_test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kinesis:*",
                "es:*",
                "firehose:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}



resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.policy.arn
}







######################################################

resource "aws_elasticsearch_domain" "test_cluster" {
  domain_name           = "datalog"
  elasticsearch_version = "OpenSearch_1.2"

  cluster_config {
    instance_type = "t3.small.elasticsearch"
    instance_count           = 1
    dedicated_master_enabled = false
    zone_awareness_enabled   = false
  }

  ebs_options {
    volume_size = 10
    volume_type = "gp2"
    ebs_enabled = true
  }
  encrypt_at_rest {
    enabled = true
  }
  node_to_node_encryption {
    enabled = true
  }
  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
  
    master_user_options {
      master_user_name     = "jeongwon"
      master_user_password = "jeongWon123*"
    }
  }
  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }


  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  #   advanced_options = {
  #     "override_main_response_version" = "true"
  #   }
}
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}


resource "aws_elasticsearch_domain_policy" "op-policy" {
  domain_name = aws_elasticsearch_domain.test_cluster.domain_name

  access_policies = <<POLICIES
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Action": "es:*",
              "Principal": {
                "AWS" : "*"
              },
              "Effect": "Allow",
              "Resource": "${aws_elasticsearch_domain.test_cluster.arn}/*"
          }
      ]
  }
  POLICIES
}




