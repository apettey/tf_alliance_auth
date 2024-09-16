locals {
  container_environment = [
    {
      name  = "PROTOCOL"
      value = var.PROTOCOL
    },
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
    },
    {
      name  = "AA_REDIS"
      value = var.AA_REDIS
    },
    {
      name  = "ESI_SSO_CLIENT_ID"
      value = var.ESI_SSO_CLIENT_ID
    },
    {
      name  = "ESI_SSO_CLIENT_SECRET"
      value = var.ESI_SSO_CLIENT_SECRET
    },
    {
      name  = "AA_EMAIL_HOST_USER"
      value = var.AA_EMAIL_HOST_USER
    },
    {
      name  = "AA_EMAIL_HOST_PASSWORD"
      value = var.AA_EMAIL_HOST_PASSWORD
    },
    {
      name  = "DJANGO_SUPERUSER_USERNAME"
      value = "admin"
    },
    {
      name  = "DJANGO_SUPERUSER_PASSWORD"
      value = "Andrew001"
    },
  ]
}