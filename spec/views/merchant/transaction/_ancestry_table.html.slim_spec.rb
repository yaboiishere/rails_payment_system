# frozen_string_literal: true

require "rails_helper"

RSpec.describe "merchant/transaction/_ancestry_table.html.slim", type: :view do
  let(:merchant) { create(:merchant) }

  let(:root_tx) { create(:authorize_transaction, merchant: merchant, amount: 100.0) }
  let(:child_tx) { create(:charge_transaction, parent_transaction: root_tx, merchant: merchant, amount: 100.0, status: "refunded") }
  let(:grand_child_tx) { create(:refund_transaction, parent_transaction: child_tx) }

  let(:presenter) { TransactionPresenter.new(grand_child_tx) }

  let(:ancestry) do
    [ TransactionPresenter.new(root_tx), TransactionPresenter.new(child_tx), TransactionPresenter.new(grand_child_tx) ]
  end

  it "renders the ancestry table with correct rows" do
    render partial: "merchant/transaction/ancestry_table", locals: {
      ancestry: ancestry,
      current_presenter: ancestry[1]
    }

    puts rendered

    expect(rendered).to have_css("table")
    expect(rendered).to include(root_tx.uuid)
    expect(rendered).to include(child_tx.uuid)
    expect(rendered).to include(merchant_transaction_path(merchant, root_tx))
    expect(rendered).not_to include(merchant_transaction_path(merchant, child_tx))
  end

  it "highlights the current transaction row" do
    render partial: "merchant/transaction/ancestry_table", locals: {
      ancestry: presenter.ancestry_chain,
      current_presenter: ancestry[1]
    }

    expect(rendered.scan(/table-primary/).count).to eq(1)
    expect(rendered).to include(root_tx.uuid)
  end
end
