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


resource "aws_ecs_task_definition" "allianceauthtask" {
  family                   = "allianceauthtask"
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
      environment = [
        {
          name  = "DOMAIN"
          value = var.DOMAIN
        },
        {
          name  = "AUTH_SUBDOMAIN"
          value = var.AUTH_SUBDOMAIN
        },
        {
          name  = "AA_DOCKER_IMAGE"
          value = var.AA_DOCKER_IMAGE
        },
        {
          name  = "AA_REDIS"
          value = var.AA_REDIS
        },
        {
          name  = "AA_SITENAME"
          value = var.AA_SITENAME
        },
        {
          name  = "AA_SECRET_KEY"
          value = var.AA_SECRET_KEY
        },
        {
          name  = "AA_DB_HOST"
          value = var.AA_DB_HOST
        },
        {
          name  = "AA_DB_NAME"
          value = var.AA_DB_NAME
        },
        {
          name  = "AA_DB_USER"
          value = var.AA_DB_USER
        },
        {
          name  = "AA_DB_PASSWORD"
          value = var.AA_DB_PASSWORD
        },
        {
          name  = "AA_EMAIL_HOST"
          value = var.AA_EMAIL_HOST
        }
      ]
      command = [
        "auth migrate",
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
      name             = "allianceauth"
      image            = var.AA_DOCKER_IMAGE
      workingDirectory = "/home/allianceauth"
      environment = [
        {
          name  = "DOMAIN"
          value = var.DOMAIN
        },
        {
          name  = "AUTH_SUBDOMAIN"
          value = var.AUTH_SUBDOMAIN
        },
        {
          name  = "AA_DOCKER_IMAGE"
          value = var.AA_DOCKER_IMAGE
        },
        {
          name  = "AA_REDIS"
          value = var.AA_REDIS
        },
        {
          name  = "AA_SITENAME"
          value = var.AA_SITENAME
        },
        {
          name  = "AA_SECRET_KEY"
          value = var.AA_SECRET_KEY
        },
        {
          name  = "AA_DB_HOST"
          value = var.AA_DB_HOST
        },
        {
          name  = "AA_DB_NAME"
          value = var.AA_DB_NAME
        },
        {
          name  = "AA_DB_USER"
          value = var.AA_DB_USER
        },
        {
          name  = "AA_DB_PASSWORD"
          value = var.AA_DB_PASSWORD
        },
        {
          name  = "AA_EMAIL_HOST"
          value = var.AA_EMAIL_HOST
        }
      ]

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "http"
        }
      ]

      workingDirectory = "/home/allianceauth/myauth"
      command = [
        "gunicorn myauth.wsgi:application",
        "--bind=0.0.0.0:8000",
        "--workers=3",
        "--timeout=120",
        "--max-requests=500",
        "--max-requests-jitter=50"
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
      name             = "allianceauth_worker_beat"
      image            = var.AA_DOCKER_IMAGE
      workingDirectory = "/home/allianceauth/myauth"
      essential        = false
      environment = [
        {
          name  = "DOMAIN"
          value = var.DOMAIN
        },
        {
          name  = "AUTH_SUBDOMAIN"
          value = var.AUTH_SUBDOMAIN
        },
        {
          name  = "AA_DOCKER_IMAGE"
          value = var.AA_DOCKER_IMAGE
        },
        {
          name  = "AA_REDIS"
          value = var.AA_REDIS
        },
        {
          name  = "AA_SITENAME"
          value = var.AA_SITENAME
        },
        {
          name  = "AA_SECRET_KEY"
          value = var.AA_SECRET_KEY
        },
        {
          name  = "AA_DB_HOST"
          value = var.AA_DB_HOST
        },
        {
          name  = "AA_DB_PASSWORD"
          value = var.AA_DB_PASSWORD
        },
        {
          name  = "AA_DB_NAME"
          value = var.AA_DB_NAME
        },
        {
          name  = "AA_DB_USER"
          value = var.AA_DB_USER
        },
        {
          name  = "AA_EMAIL_HOST"
          value = var.AA_EMAIL_HOST
        }
      ]
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
      essential        = false
      environment = [
        {
          name  = "DOMAIN"
          value = var.DOMAIN
        },
        {
          name  = "AUTH_SUBDOMAIN"
          value = var.AUTH_SUBDOMAIN
        },
        {
          name  = "AA_DOCKER_IMAGE"
          value = var.AA_DOCKER_IMAGE
        },
        {
          name  = "AA_REDIS"
          value = var.AA_REDIS
        },
        {
          name  = "AA_SITENAME"
          value = var.AA_SITENAME
        },
        {
          name  = "AA_SECRET_KEY"
          value = var.AA_SECRET_KEY
        },
        {
          name  = "AA_DB_HOST"
          value = var.AA_DB_HOST
        },
        {
          name  = "AA_DB_PASSWORD"
          value = var.AA_DB_PASSWORD
        },
        {
          name  = "AA_DB_NAME"
          value = var.AA_DB_NAME
        },
        {
          name  = "AA_DB_USER"
          value = var.AA_DB_USER
        },
        {
          name  = "AA_EMAIL_HOST"
          value = var.AA_EMAIL_HOST
        }
      ]
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

resource "aws_ecs_service" "allianceauth" {
  name            = "allianceauth"
  cluster         = var.ESC_CLUSTER_ID
  task_definition = aws_ecs_task_definition.allianceauthtask.arn
  desired_count   = 1
  launch_type     = "EC2"

  # network_configuration {
  #   subnets         = var.SUBNET_IDS
  #   security_groups = var.SECURITY_GROUPS
  # }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "allianceauth"
    container_port   = 8000
  }
}
