# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Idempotency do
  let(:user) { create(:user) }
  let(:key) { SecureRandom.uuid }
  let(:ttl) { 10.minutes }
  let(:idempotency) { described_class.new(user: user, key: key, ttl: ttl) }

  let(:response_data) { { message: "OK", data: { value: 42 } } }
  let(:status_code) { 201 }

  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  describe "#cache_key" do
    it "generates a namespaced key using user ID" do
      expect(idempotency.cache_key).to eq("idempotency:#{user.id}:#{key}")
    end
  end

  describe "#cached?" do
    it "returns false if nothing is cached" do
      expect(idempotency.cached?).to be false
    end

    it "returns true after storing data" do
      idempotency.store(response: response_data, status: status_code)
      expect(idempotency.cached?).to be true
    end
  end

  describe "#store and #read" do
    before do
      idempotency.store(response: response_data, status: status_code)
    end

    it "stores and retrieves the full response hash" do
      cached = idempotency.read
      expect(cached).to be_a(Hash)
      expect(cached[:body]).to eq(response_data)
      expect(cached[:status]).to eq(status_code)
    end

    it "respects TTL" do
      expect(Rails.cache.exist?(idempotency.cache_key)).to be true
    end
  end
end
