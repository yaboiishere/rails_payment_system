# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteOldTransactionsJob, type: :job do
  it 'deletes transactions older than 1 hour' do
    old = create(:transaction, created_at: 2.hours.ago)
    recent = create(:transaction, created_at: 10.minutes.ago)

    expect {
      described_class.perform_async
    }.to change(described_class.jobs, :size).by(1)

    described_class.drain

    expect(Transaction.exists?(recent.id)).to be true
    expect(Transaction.exists?(old.id)).to be false
  end
end
