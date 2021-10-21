resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster-name
}


data "template_file" "task_definition1_template" {
  template = file("task_definition1.json.tpl")
}

data "template_file" "task_definition2_template" {
  template = file("task_definition2.json.tpl")
}

resource "aws_ecs_task_definition" "task_definition1" {
  family                   = "worker"
  network_mode             = "awsvpc"
  container_definitions    = data.template_file.task_definition1_template.rendered
  memory                   = 512
  cpu                      = 256
  task_role_arn            = data.aws_iam_role.ecs_agent.arn
  execution_role_arn       = data.aws_iam_role.ecs_agent.arn
  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_task_definition" "task_definition2" {
  family                   = "backend"
  network_mode             = "awsvpc"
  container_definitions    = data.template_file.task_definition2_template.rendered
  memory                   = 512
  cpu                      = 256
  task_role_arn            = data.aws_iam_role.ecs_agent.arn
  execution_role_arn       = data.aws_iam_role.ecs_agent.arn
  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_service" "worker-svc" {
  name            = "worker-svc"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition1.family
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
      security_groups = [aws_security_group.ecs_tasks.id]
      subnets         = aws_subnet.private_subnet.*.id
    }

  load_balancer {
      target_group_arn = aws_lb_target_group.nlb_tg.arn
      container_name   = "worker"
      container_port   = 80
    }
  depends_on = [
      aws_ecs_task_definition.task_definition1,
    ]
}

resource "aws_ecs_service" "backend-svc" {
  name            = "backend-svc"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition2.family
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
      security_groups = [aws_security_group.ecs_tasks.id]
      subnets         = aws_subnet.private_subnet.*.id
    }

  load_balancer {
      target_group_arn = aws_lb_target_group.alb_target_group.arn
      container_name   = "backend"
      container_port   = 6379
    }
  depends_on = [
      aws_ecs_task_definition.task_definition2,
    ]
}

