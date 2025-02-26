DfE::Analytics.configure do |config|
  # Whether to log events instead of sending them to BigQuery.
  #
  config.log_only = false

  # Whether to use ActiveJob or dispatch events immediately.
  #
  config.async = true

  # Which ActiveJob queue to put events on
  #
  # config.queue = :default

  # The name of the BigQuery table we’re writing to.
  #
  config.bigquery_table_name = ENV.fetch("BIGQUERY_TABLE_NAME", nil)

  # The name of the BigQuery project we’re writing to.
  #
  config.bigquery_project_id = ENV.fetch("BIGQUERY_PROJECT_ID", nil)

  # The name of the BigQuery dataset we're writing to.
  #
  config.bigquery_dataset = ENV.fetch("BIGQUERY_DATASET", nil)

  # Service account JSON key for the BigQuery API. See
  # https://cloud.google.com/bigquery/docs/authentication/service-account-file
  #
  config.bigquery_api_json_key = ENV.fetch("BIG_QUERY_API_JSON_KEY", nil)

  # Passed directly to the retries: option on the BigQuery client
  #
  # config.bigquery_retries = 3

  # Passed directly to the timeout: option on the BigQuery client
  #
  # config.bigquery_timeout = 120

  # A proc which returns true or false depending on whether you want to
  # enable analytics. You might want to hook this up to a feature flag or
  # environment variable.
  #
  # config.enable_analytics = proc { true }

  # The environment we’re running in. This value will be attached
  # to all events we send to BigQuery.
  #
  config.environment = ENV.fetch("RAILS_ENV", "development")
end
