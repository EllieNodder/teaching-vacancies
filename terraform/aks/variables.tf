variable "cluster" {
  description = "AKS cluster where this app is deployed. Either 'test' or 'production'"
}
variable "namespace" {
  description = "AKS namespace where this app is deployed"
}
variable "environment" {
  description = "Name of the deployed environment in AKS"
}
variable "parameter_store_environment" {
  description = "Name of the parameter store environment in AWS"
}
variable "azure_credentials_json" {
  default     = null
  description = "JSON containing the service principal authentication key when running in automation"
}
variable "azure_resource_prefix" {
  description = "Standard resource prefix. Usually s189t01 (test) or s189p01 (production)"
}
variable "config_short" {
  description = "Short name of the environment configuration, e.g. dv, st, pd..."
}
variable "config" {
  description = "the environment configuration, e.g. development, staging, production..."
}
variable "service_name" {
  description = "Full name of the service. Lowercase and hyphen separated"
}
variable "service_short" {
  description = "Short name to identify the service. Up to 6 charcters."
}
variable "deploy_azure_backing_services" {
  default     = true
  description = "Deploy real Azure backing services like databases, as opposed to containers inside of AKS"
}
variable "enable_postgres_ssl" {
  default     = true
  description = "Enforce SSL connection from the client side"
}
variable "enable_monitoring" {
  default     = false
  description = "Enable monitoring and alerting"
}
variable "azure_enable_backup_storage" {
  default     = true
  description = "Create storage account for database backup"
}
variable "docker_image" {
  description = "Docker image full name to identify it in the registry. Includes docker registry, repository and tag e.g.: ghcr.io/dfe-digital/teacher-pay-calculator:673f6309fd0c907014f44d6732496ecd92a2bcd0"
}
variable "web_app_start_command" {
  default = ["bundle", "exec", "rails", "db:migrate",  "&&", "rails", "s"]
}
locals {
  aws_region = "eu-west-2"

  azure_credentials = try(jsondecode(var.azure_credentials_json), null)

  postgres_ssl_mode = var.enable_postgres_ssl ? "require" : "disable"

  app_env_values  = yamldecode(file("${path.module}/config/${var.config}_app_env.yml"))




}
