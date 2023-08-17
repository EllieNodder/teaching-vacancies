data "aws_ssm_parameter" "app_env_api_key_big_query" {
  name = "/teaching-vacancies/${var.parameter_store_environment}/app/BIG_QUERY_API_JSON_KEY"
}

data "aws_ssm_parameter" "app_env_api_key_google" {
  name = "/teaching-vacancies/${var.parameter_store_environment}/app/GOOGLE_API_JSON_KEY"
}

data "aws_ssm_parameter" "app_env_secrets" {
  name = "/teaching-vacancies/${var.parameter_store_environment}/app/secrets"
}
