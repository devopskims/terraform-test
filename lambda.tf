# resource "aws_iam_role" "iam_for_lambda" {
#   name = "iam_for_lambda"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }


# resource "aws_iam_policy" "lambda-terraform-policy" {
#   name        = "lambda-terraform-policy"
#   description = "policy"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "Stmt1428341300017",
#       "Action": [
#         "dynamodb:DeleteItem",
#         "dynamodb:GetItem",
#         "dynamodb:PutItem",
#         "dynamodb:Query",
#         "dynamodb:Scan",
#         "dynamodb:UpdateItem"
#       ],
#       "Effect": "Allow",
#       "Resource": "*"
#     },
#     {
#       "Sid": "",
#       "Resource": "*",
#       "Action": [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ],
#       "Effect": "Allow"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "lambda-attach" {
#   role       = aws_iam_role.iam_for_lambda.name
#   policy_arn = aws_iam_policy.lambda-terraform-policy.arn
# }

# # iam role / policy
# ###########################################################
# # driver lambda

# resource "aws_lambda_function" "driver-terraform" {
#   # If the file is not in the current working directory you will need to include a 
#   # path.module in the filename.
#   filename      = "lambda_function_payload.zip"
#   function_name = "lambda_function_name"
#   role          = aws_iam_role.iam_for_lambda.arn
#   handler       = "index.test"

#   # The filebase64sha256() function is available in Terraform 0.11.12 and later
#   # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
#   # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
# #   source_code_hash = filebase64sha256("lambda_function_payload.zip")

#   runtime = "nodejs16.x"

# #   environment {
# #     variables = {
# #       foo = "bar"
# #     }
# #   }
# }

# resource "aws_lambda_invocation" "example" {
#   function_name = aws_lambda_function.lambda-terraform-policy.function_name

#   triggers = {
#     redeployment = sha1(jsonencode([
#       aws_lambda_function.example.environment
#     ]))
#   }

#   input = jsonencode({
#     key1 = "value1"
#     key2 = "value2"
#   })
# }

# resource "aws_dynamodb_table" "table" {
#   name           = "driver-location"
#   hash_key       = "LockID"
#   billing_mode   = "PAY_PER_REQUEST"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

# ################################################33

# resource "aws_lambda_function" "location-terraform" {
#   # If the file is not in the current working directory you will need to include a 
#   # path.module in the filename.
#   filename      = "lambda_function_payload.zip"
#   function_name = "lambda_function_name"
#   role          = aws_iam_role.iam_for_lambda.arn
#   handler       = "index.test"

#   # The filebase64sha256() function is available in Terraform 0.11.12 and later
#   # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
#   # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
# #   source_code_hash = filebase64sha256("lambda_function_payload.zip")

#   runtime = "Python3.9"

# #   environment {
# #     variables = {
# #       foo = "bar"
# #     }
# #   }
# }

# data "archive_file" "lambda-location" {
#   type             = "zip"
#   source_file      = "${path.module}/../lambda/my-function/lambda_function.py"
#   output_file_mode = "0666"
#   output_path      = "${path.module}/files/my-deployment-package.zip"
# }

# ##############################################

# resource "aws_lambda_function" "intergration-terraform" {
#   # If the file is not in the current working directory you will need to include a 
#   # path.module in the filename.
#   filename      = "lambda_function_payload.zip"
#   function_name = "lambda_function_name"
#   role          = aws_iam_role.iam_for_lambda.arn
#   handler       = "index.test"

#   # The filebase64sha256() function is available in Terraform 0.11.12 and later
#   # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
#   # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
# #   source_code_hash = filebase64sha256("lambda_function_payload.zip")

#   runtime = "Python3.9"

# #   environment {
# #     variables = {
# #       foo = "bar"
# #     }
# #   }
# }

