variable "PROTOCOL" {
  description = "The protocol for the Alliance Auth instance"
  type        = string
  default     = "http://"
}

variable "DOMAIN" {
  description = "The domain for the Alliance Auth instance"
  type        = string
}

variable "AA_DOCKER_IMAGE" {
  description = "The Docker image for Alliance Auth"
  type        = string
  default     = "registry.gitlab.com/allianceauth/allianceauth/auth:v4.1.0"
}

variable "AUTH_SUBDOMAIN" {
  description = "The subdomain for the Alliance Auth instance"
  type        = string
}

variable "AA_REDIS" {
  description = "Redis endpoint for Alliance Auth"
  type        = string
  sensitive   = false
}

variable "AA_SITENAME" {
  description = "The name of the site"
  type        = string
  default     = "Alliance Auth"
}

variable "AA_SECRET_KEY" {
  description = "The secret key for the Django application"
  type        = string
  sensitive   = true
}

variable "AA_DB_HOST" {
  description = "The hostname of the MariaDB database"
  type        = string
  default     = "localhost"
}

variable "AA_DB_NAME" {
  description = "The name of the MariaDB database"
  type        = string
  default     = "allianceauth"
}

variable "AA_DB_USER" {
  description = "The username for the MariaDB database"
  type        = string
  default     = "allianceauth"
}

variable "AA_DB_PASSWORD" {
  description = "The password for the MariaDB database"
  type        = string
  default     = "allianceauth"
}

variable "AA_EMAIL_HOST" {
  description = "The email host for the Django application"
  type        = string
  default     = "localhost"
}

variable "AA_EMAIL_PORT" {
  description = "The email port for the Django application"
  type        = number
  default     = 587
}

variable "AA_EMAIL_HOST_USER" {
  description = "The email host user for the Django application"
  type        = string
  default     = ""
}

variable "AA_EMAIL_HOST_PASSWORD" {
  description = "The email host password for the Django application"
  type        = string
  sensitive   = true
  default     = ""
}

variable "AA_EMAIL_USE_TLS" {
  description = "Whether to use TLS for the email host"
  type        = bool
  default     = true
}

variable "AA_DEFAULT_FROM_EMAIL" {
  description = "The default from email for the Django application"
  type        = string
  default     = "noreply@localhost"
}

variable "ESI_SSO_CLIENT_ID" {
  description = "The client ID for the ESI SSO application"
  type        = string
  sensitive   = true
}

variable "ESI_SSO_CLIENT_SECRET" {
  description = "The client secret for the ESI SSO application"
  type        = string
  sensitive   = true
}

variable "ESI_USER_CONTACT_EMAIL" {
  description = "The contact email for the ESI user"
  type        = string
}

variable "GRAFANA_DB_PASSWORD" {
  description = "The password for the Grafana database"
  type        = string
  sensitive   = true
}

variable "GF_SECURITY_ADMIN_USERNAME" {
  description = "Grafana admin username"
  type        = string
  sensitive   = false
  default     = "admin"
}

variable "GF_SECURITY_ADMIN_PASSWORD" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = "admin"

}

variable "CLOUDWATCH_LOG_GROUP" {
  description = "The CloudWatch log group for the Alliance Auth instance"
  type        = string
  default     = "/ecs/allianceauth_server"
}

variable "AWS_REGION" {
  description = "The AWS region for the Alliance Auth instance"
  type        = string
  default     = "eu-west-1"

}

variable "SECURITY_GROUPS" {
  description = "The security groups for the Alliance Auth instance"
  type        = list(string)
}

variable "SUBNET_IDS" {
  description = "The subnets for the Alliance Auth instance"
  type        = list(string)
}

variable "ESC_CLUSTER_ID" {
  description = "value of the ECS cluster ID"
  type        = string
}

variable "VPC_ID" {
  description = "VPC ID to be used for the load balancer"
  type        = string
}