# Define provider and region
provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attach policy to allow basic Lambda execution
resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda_basic_execution"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.lambda_role.name]
}

# Create the Lambda function
resource "aws_lambda_function" "hello_world_lambda_12" {
  function_name    = "hello_world_lambda_test"
  handler          = "hello_world.lambda_handler"
  runtime          = "python3.8"  # Change to your desired runtime
  filename         = "hello_world.zip"  # Provide the path to your Lambda function code
  source_code_hash = filebase64sha256("hello_world.zip")
  role             = aws_iam_role.lambda_role.arn

  # (Optional) Environment variables
  environment {
    variables = {
      ENV_VAR_NAME = "ENV_VAR_VALUE"
    }
  }
}

