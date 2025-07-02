# frozen_string_literal: true

class Idempotency
  attr_reader :user, :key, :cache_key, :ttl

  def initialize(user:, key:, ttl: 1.hours)
    @user = user
    @key = key
    @ttl = ttl
    @cache_key = "idempotency:#{user.id}:#{key}"
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
