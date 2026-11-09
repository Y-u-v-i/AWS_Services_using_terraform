terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  access_key                  = "flociadmin"
  secret_key                  = "flociadmin"
  region                      = "us-east-1"

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  endpoints {
    s3       = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
    iam      = "http://localhost:4566"
    lambda   = "http://localhost:4566"
    sqs      = "http://localhost:4566"
    sns      = "http://localhost:4566"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_dynamodb_table" "employees" {
name = "Employees"
billing_mode = "PAY_PER_REQUEST"
hash_key = "id"
attribute {
name = "id"
type = "S"
}
}
resource "aws_dynamodb_table_item" "emp1" {
table_name = aws_dynamodb_table.employees.name
hash_key = aws_dynamodb_table.employees.hash_key
item = <<ITEM
{
"id": {"S": "101"},
"name": {"S": "John"},
"department": {"S": "IT"},
"salary": {"N": "50000"}
}
ITEM
}
resource "aws_dynamodb_table_item" "emp2" {
table_name = aws_dynamodb_table.employees.name
hash_key = aws_dynamodb_table.employees.hash_key
item = <<ITEM
{
"id": {"S":"102"},
"name":{"S": "Stacy"},
"department": {"S":"Phisotherapy"},
"salary": {"S":"60000"}
}
ITEM
}
resource "aws_dynamodb_table_item" "emp3" {
table_name = aws_dynamodb_table.employees.name
hash_key = aws_dynamodb_table.employees.hash_key
item = <<ITEM
{
"id":{"S":"1023"},
"name":{"S":"Gwen"},
"department":{"S":"Cardiology"},
"salary":{"S":"70000"}
}
ITEM
}
resource "aws_sqs_queue" "orders" {
  name = "orders-queue"
}

resource "null_resource" "send_shipping_msg"{

  provisioner "local-exec" {
    command = <<EOT
    aws --endpoint-url=http://localhost:4566 sqs send-message \
    --queue-url http://localhost:4566/000000000000/orders-queue \
    --message-body '{"shipment_id":1021, "status":"SHIPPED"}'
    EOT
  }

  depends_on = [ aws_sqs_queue.orders ]
}

resource "null_resource" "send_shipping_msg_1021"{
  provisioner "local-exec"{
    command = <<EOT
    aws --endpoint-url=http://localhost:4566 sqs send-message \
    --queue-url http://localhost:4566/000000000000/orders-queue  \
    --message-body '{"shipment_id":1203,"status":"SHIPPED"}'
    EOT
  }
  depends_on = [aws_sqs_queue.orders]
}

resource "null_resource" "send_shipping_msg_1022"{
  provisioner "local-exec" {
    command = <<EOT
    aws --endpoint-url=http://localhost:4566 sqs send-message \
    --queue-url http://localhost:4566/000000000000/orders-queue \
    --message-body '{"shipment_id":1033,"status":"received"}'
    EOT
  }
  depends_on = [ aws_sqs_queue.orders ]
}
resource "aws_lambda_function" "hello" {
  function_name = "hello-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  filename      = "lambda.zip"
}