resource "aws_api_gateway_rest_api" "driver-terraform" {
  name = "driver-terraform"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "driver-terraform" {
  parent_id   = aws_api_gateway_rest_api.driver-terraform.root_resource_id
  path_part   = "driver-terraform"
  rest_api_id = aws_api_gateway_rest_api.driver-terraform.id
}

resource "aws_api_gateway_method" "driver-terraform" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.driver-terraform.id
  rest_api_id   = aws_api_gateway_rest_api.driver-terraform.id
}


resource "aws_api_gateway_integration" "driver-terraform" {
  http_method             = aws_api_gateway_method.driver-terraform.http_method
  resource_id             = aws_api_gateway_resource.driver-terraform.id
  rest_api_id             = aws_api_gateway_rest_api.driver-terraform.id
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:ap-northeast-2:kinesis:action/PutRecord"
  credentials             = aws_iam_role.api-gateway-role.arn
  timeout_milliseconds    = 29000
  request_templates = {
    "application/json" = <<EOF
{"StreamName": "datastream-terraform","Data": "$util.base64Encode($input.body)","PartitionKey": "$context.requestId"}
EOF
  }

}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.driver-terraform.id
  resource_id = aws_api_gateway_resource.driver-terraform.id
  http_method = aws_api_gateway_method.driver-terraform.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "driver-terraform" {
  depends_on = [
    aws_api_gateway_method.driver-terraform,
    aws_api_gateway_integration.driver-terraform
  ]
  rest_api_id = aws_api_gateway_rest_api.driver-terraform.id
  resource_id = aws_api_gateway_resource.driver-terraform.id
  http_method = aws_api_gateway_method.driver-terraform.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
  response_templates = {
    "application/json" = <<EOF
EOF
  }
}



resource "aws_api_gateway_deployment" "driver-terraform" {
  rest_api_id = aws_api_gateway_rest_api.driver-terraform.id

  triggers = {

    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.driver-terraform.id,
      aws_api_gateway_method.driver-terraform.id,
      aws_api_gateway_integration.driver-terraform.id,
    ]))
  }

    lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "data" {
  deployment_id = aws_api_gateway_deployment.driver-terraform.id
  rest_api_id   = aws_api_gateway_rest_api.driver-terraform.id
  stage_name    = "data"
}


#########################################
# iam role / policy

resource "aws_iam_role" "api-gateway-role" {
  name = "api-gateway-role-tf"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "gatewaypolicy" {
  name        = "api-gateway-policy-tf"
  description = "A test policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kinesis:PutRecord"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "gateway-attach" {
  role       = aws_iam_role.api-gateway-role.name
  policy_arn = aws_iam_policy.gatewaypolicy.arn
}


