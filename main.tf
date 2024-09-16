


resource "aws_cloudwatch_log_group" "allianceauth_ecs_log_group" {
  name              = var.CLOUDWATCH_LOG_GROUP
  retention_in_days = 1 # Adjust retention period as needed
}

resource "aws_iam_role" "allianceauth_ecs_task_execution_role" {
  name = "allianceauthECSTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "allianceauth_ecs_task_execution_role_policy" {
  role       = aws_iam_role.allianceauth_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "allianceauth_ecs_task_execution_role_logs_policy" {
  role       = aws_iam_role.allianceauth_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "allianceauth_ecs_task_execution_role_ecr_policy" {
  role       = aws_iam_role.allianceauth_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role" "allianceauth_ecs_task_role" {
  name = "allianceAuthECSTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_ecs_task_definition" "allianceauth_web" {
  family                   = "allianceauth_web"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.allianceauth_ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.allianceauth_ecs_task_role.arn
  memory                   = 450
  cpu                      = 1024

  container_definitions = jsonencode([
    {
      name             = "allianceauth_migration"
      image            = var.AA_DOCKER_IMAGE
      essential        = false
      workingDirectory = "/home/allianceauth"
      environment      = local.container_environment
      command = [
        "python /home/allianceauth/myauth/manage.py migrate",
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.CLOUDWATCH_LOG_GROUP
          "awslogs-region"        = var.AWS_REGION
          "awslogs-stream-prefix" = "ecs"
        }
      }
    },
    {
      name             = "allianceauth_check"
      image            = var.AA_DOCKER_IMAGE
      essential        = false
      workingDirectory = "/home/allianceauth"
      environment      = local.container_environment
      command          = ["python /home/allianceauth/myauth/manage.py check"]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.CLOUDWATCH_LOG_GROUP
          "awslogs-region"        = var.AWS_REGION
          "awslogs-stream-prefix" = "ecs"
        }
      }
    },
    {
      name             = "allianceauth"
      image            = var.AA_DOCKER_IMAGE
      workingDirectory = "/home/allianceauth"
      environment      = local.container_environment

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "http"
        }
      ]

      workingDirectory = "/home/allianceauth/myauth"
      command = [
        "service nginx start && python manage.py collectstatic --noinput &&  gunicorn myauth.wsgi:application --bind=0.0.0.0:4080 --workers=3 --timeout=120 --max-requests=500 --max-requests-jitter=50"
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.CLOUDWATCH_LOG_GROUP
          "awslogs-region"        = var.AWS_REGION
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
  depends_on = [
    aws_lb_listener.ecs_lb_listener
  ]
}




resource "aws_ecs_task_definition" "allianceauth_workers" {
  family                   = "allianceauth_workers"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.allianceauth_ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.allianceauth_ecs_task_role.arn
  memory                   = 256
  cpu                      = 512

  container_definitions = jsonencode([
    {
      name             = "allianceauth_worker_beat"
      image            = var.AA_DOCKER_IMAGE
      workingDirectory = "/home/allianceauth/myauth"
      essential        = true
      environment      = local.container_environment
      entryPoint : [
        "sh", "-c"
      ]
      command = [
        "celery -A myauth beat"
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.CLOUDWATCH_LOG_GROUP
          "awslogs-region"        = var.AWS_REGION
          "awslogs-stream-prefix" = "ecs"
        }
      }
    },
    {
      name             = "allianceauth_worker"
      image            = var.AA_DOCKER_IMAGE
      workingDirectory = "/home/allianceauth/myauth"
      essential        = true
      environment      = local.container_environment
      entryPoint : [
        "sh", "-c"
      ]
      command = [
        "celery -A myauth worker --pool=threads --concurrency=10 -n worker_1"
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.CLOUDWATCH_LOG_GROUP
          "awslogs-region"        = var.AWS_REGION
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
  depends_on = [
    aws_lb_listener.ecs_lb_listener
  ]
}


resource "aws_ecs_service" "allianceauth_web" {
  name            = "allianceauth_web"
  cluster         = var.ESC_CLUSTER_ID
  task_definition = aws_ecs_task_definition.allianceauth_web.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "allianceauth"
    container_port   = 8080
  }
}


resource "aws_ecs_service" "allianceauth_workers" {
  name            = "allianceauth_workers"
  cluster         = var.ESC_CLUSTER_ID
  task_definition = aws_ecs_task_definition.allianceauth_workers.arn
  desired_count   = 1
  launch_type     = "EC2"

}