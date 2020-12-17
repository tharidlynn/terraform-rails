resource "aws_ecs_cluster" "docker_rails_cluster" {
  name = "docker-rails-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "docker_rails" {
  name            = "docker-rails"
  cluster         = aws_ecs_cluster.docker_rails_cluster.id
  task_definition = aws_ecs_task_definition.docker_rails_task.arn

  launch_type = "FARGATE"

  desired_count = 1

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.subnets
    assign_public_ip = true
  }
}


resource "aws_ecs_task_definition" "docker_rails_task" {
  family = "docker-rails"

  container_definitions = <<EOF
[
  {
    "name": "docker-rails",
    "image": "${var.aws_ecr_repository}",
    "cpu": ${var.cpu},
    "memory": ${var.memory},
    "portMappings": [
      {
        "containerPort": ${var.rails_port},
        "hostPort": ${var.rails_port},
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "ap-southeast-1",
        "awslogs-group": "docker-rails",
        "awslogs-stream-prefix": "docker-rails-service"
      }
    }
  }
]
EOF

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  tags = {
    Environment = "development"
  }

}


resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-sg"
  description = "allow inbound access"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 3000
    to_port     = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "docker_rails" {
  name              = "docker-rails"
  retention_in_days = 1
}
