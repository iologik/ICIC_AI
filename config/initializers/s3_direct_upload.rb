# frozen_string_literal: true

S3DirectUpload.config do |c|
  c.access_key_id = ENV.fetch('aws_access_key_id', nil) # your access key id
  c.secret_access_key = ENV.fetch('aws_secret_access_key', nil) # your secret access key
  c.bucket = ENV.fetch('bucket', nil) # your bucket name
  c.region = 's3-us-west-1'
  # c.region = "s3-us-west-2" # region prefix of your bucket url. This is _required_ for the non-default AWS region, eg. "s3-eu-west-1"
  c.url = "https://#{c.bucket}.#{c.region}.amazonaws.com/" # S3 API endpoint (optional), eg. "https://#{c.bucket}.s3.amazonaws.com/"
end
