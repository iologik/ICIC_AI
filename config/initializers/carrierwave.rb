# frozen_string_literal: true

CarrierWave.configure do |config|
  if Rails.env.test? || Rails.env.development?
    config.storage :file
    config.asset_host = 'http://localhost:3000'
  else
    # config.fog_use_ssl_for_aws = true
    config.fog_directory = ENV.fetch('bucket', nil)
    config.fog_public     = true
    config.fog_attributes = { 'Cache-Control': 'max-age=315576000' }
    # config.asset_host = 'https://s3.amazonaws.com/website'

    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV.fetch('aws_access_key_id', nil),
      aws_secret_access_key: ENV.fetch('aws_secret_access_key', nil),
    }
    config.storage = :fog
  end
end
