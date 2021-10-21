data "aws_iam_role" "ecs_agent" {
  name = "Mumbai-ECSTaskExecutionRole"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name = "ecs/test-worker"
}

