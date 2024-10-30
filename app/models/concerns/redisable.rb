# frozen_string_literal: true

module Redisable
  extend ActiveSupport::Concern

  private

  # rubocop:disable Style/GlobalVars
  def redis
    $redis ||= Redis.new(url: ENV.fetch('REDIS_URL', nil), ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
  end
  # rubocop:enable Style/GlobalVars
end
