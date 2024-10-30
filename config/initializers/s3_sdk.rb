# frozen_string_literal: true

require 'aws-sdk-core'

Aws.config[:credentials] = Aws::Credentials.new(ENV.fetch('aws_access_key_id', nil), ENV.fetch('aws_secret_access_key', nil))
# S3.new will now use the credentials specified in AWS.config
