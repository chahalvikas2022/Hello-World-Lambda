provider "aws" {
  region = "us-east-1"  # Choose your desired region
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the AWSLambdaBasicExecutionRole managed policy to the role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Archive the Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/hello_world.py"
  output_path = "${path.module}/hello_world.zip"
}

# Create the Lambda function
resource "aws_lambda_function" "hello_world" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "hello_world_lambda"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "hello_world.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
}

# Allow invocation of the Lambda function using AWS CLI
resource "aws_lambda_permission" "allow_invoke" {
  statement_id  = "AllowExecutionFromCLI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "lambda.amazonaws.com"
}

output "lambda_function_name" {
  value = aws_lambda_function.hello_world.function_name
}
