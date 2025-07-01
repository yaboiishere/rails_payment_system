# frozen_string_literal: true

class DeleteOldTransactionsJob < ApplicationJob
  queue_as :default

  def perform
    Transaction.where("created_at < ?", 1.hour.ago).delete_all
  end
end
