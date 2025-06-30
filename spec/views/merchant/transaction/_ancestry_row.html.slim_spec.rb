# frozen_string_literal: true

require "rails_helper"

RSpec.describe "merchant/transaction/_ancestry_row.html.slim", type: :view do
  let(:merchant) { create(:merchant) }
  let(:transaction) { create(:charge_transaction, uuid: "tx-123", merchant: merchant, amount: 100.0, status: "approved") }
  let(:presenter) { TransactionPresenter.new(transaction) }

  it "renders a table row for the transaction" do
    render partial: "merchant/transaction/ancestry_row", locals: { presenter: presenter, is_current: false }

    expect(rendered).to include("Charge")
    expect(rendered).to include(transaction.parent_transaction.uuid)
    expect(rendered).to include("$100.00")
    expect(rendered).to include("Approved")
    expect(rendered).to include(merchant_transaction_path(merchant, transaction))
  end

  it "adds highlight class when is_current is true" do
    render partial: "merchant/transaction/ancestry_row", locals: { presenter: presenter, is_current: true }

    expect(rendered).to include("table-primary")
    expect(rendered).to include("fw-bold")
  end
end
