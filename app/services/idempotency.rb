# frozen_string_literal: true

class Idempotency
  attr_reader :user, :key, :request_hash, :cache_key, :ttl

  def initialize(user:, key:, request_body:, ttl: 1.hours)
    @user = user
    @key = key
    @request_hash = Digest::SHA256.hexdigest(request_body.to_s)
    @ttl = ttl
    @cache_key = "idempotency:#{user.id}:#{key}:#{request_hash}"
  end

  def cached?
    Rails.cache.exist?(cache_key)
  end

  def read
    Rails.cache.read(cache_key)
  end

  def store(response:, status:)
    Rails.cache.write(
      cache_key,
      { body: response, status: status },
      expires_in: ttl
    )
  end
end
