require "rails_helper"

RSpec.describe "merchant/show.html.slim", type: :view do
  it "displays merchant details and transactions" do
    merchant = create(:merchant, email: "test@example.com", total_transaction_sum: 123.45)
    tx = create(:charge_transaction, merchant: merchant, amount: 123.45)

    assign(:merchant, MerchantPresenter.new(merchant))

    allow(view).to receive(:render).and_call_original

    render

    expect(rendered).to include("test@example.com")
    expect(rendered).to include("$123.45")
    expect(rendered).to have_css("table")
    expect(rendered).to include("Transaction UUID")
    expect(rendered).to include(tx.uuid.to_s)
  end
end
