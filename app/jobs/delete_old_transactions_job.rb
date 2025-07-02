# frozen_string_literal: true

require "sidekiq"

class DeleteOldTransactionsJob
  include Sidekiq::Job
  sidekiq_options queue: "default"

  def perform
    Transaction.where("created_at < ?", 1.hour.ago).delete_all
  end
end
