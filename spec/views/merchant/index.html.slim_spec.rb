require "rails_helper"

RSpec.describe "merchant/index.html.slim", type: :view do
  it "displays a table of merchants" do
    merchant1 = create(:merchant, email: "test1@example.com")
    merchant2 = create(:merchant, email: "test2@example.com")
    assign(:merchant_presenters, [ MerchantPresenter.new(merchant1), MerchantPresenter.new(merchant2) ])

    render

    expect(rendered).to include("test1@example.com")
    expect(rendered).to include("test2@example.com")
    expect(rendered).to have_css("table")
  end
end
