require "rails_helper"

RSpec.describe "transaction/show.html.slim", type: :view do
  let(:merchant) { create(:merchant, email: "merchant@payment.com") }

  let(:parent_transaction) do
    create(:authorize_transaction, merchant: merchant)
  end

  let(:transaction) do
    create(
      :charge_transaction,
      uuid: "abc-123",
      amount: 150.0,
      merchant: merchant,
      customer_email: "customer@example.com",
      customer_phone: "+123456789",
      parent_transaction: parent_transaction,
      status: "approved",
      created_at: Time.current
    )
  end

  let(:presenter) { TransactionPresenter.new(transaction) }

  before do
    assign(:transaction_presenter, presenter)
    render
  end

  it "renders the page title" do
    expect(rendered).to include("Transaction Details")
  end

  it "shows the UUID" do
    expect(rendered).to include(transaction.uuid)
  end

  it "shows the type badge" do
    expect(rendered).to include("Charge") # text from type_label_badge
    expect(rendered).to include("badge") # basic check for styling
  end

  it "shows the status badge" do
    expect(rendered).to include(transaction.status.titleize)
  end

  it "shows the amount formatted" do
    expect(rendered).to include("$150.00")
  end

  it "shows the customer email and phone" do
    expect(rendered).to include("customer@example.com")
    expect(rendered).to include("+123456789")
  end

  it "shows the parent transaction UUID" do
    expect(rendered).to include(parent_transaction.uuid)
  end

  it "links to the merchant" do
    expect(rendered).to include(merchant.name)
    expect(rendered).to include(merchant_path(merchant))
  end
end
