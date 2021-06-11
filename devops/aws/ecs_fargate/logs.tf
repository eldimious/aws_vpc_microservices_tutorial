# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "books_api_log_group" {
  name              = "/ecs/books_api"
  retention_in_days = 30

  tags = {
    Name = "books_api_log_group"
  }
}

resource "aws_cloudwatch_log_stream" "books_api_log_stream" {
  name           = "books_api_log_stream"
  log_group_name = aws_cloudwatch_log_group.books_api_log_group.name
}

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "users_api_log_group" {
  name              = "/ecs/users_api"
  retention_in_days = 30

  tags = {
    Name = "users_api_log_group"
  }
}

resource "aws_cloudwatch_log_stream" "users_api_log_stream" {
  name           = "users_api_log_stream"
  log_group_name = aws_cloudwatch_log_group.users_api_log_group.name
}