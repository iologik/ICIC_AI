# frozen_string_literal: true

class DependentCache
  def self.fetch(name, dependencies = nil, expiration = nil)
    key = cache_key(name, dependencies)

    unless (result = Rails.cache.read(key))
      result = yield
      Rails.cache.write(key, result, expires_in: expiration)
    end

    result
  end

  def self.cache_key(name, dependencies)
    dependency_sha = Digest::SHA1.base64digest(
      dependencies.to_json.parameterize
    )
    "#{name}_#{dependency_sha}"
  end
end
