# frozen_string_literal: true

require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'Transaction view', type: :system do
  let(:merchant) { create(:merchant, email: 'merchant@example.com', password: 'Secret123@', name: 'Merchant 4', status: :active) }
  let(:customer_email) { 'client@example.com' }
  let(:customer_phone) { '1234567890' }

  let(:authorize) do
    create(:authorize_transaction,
           merchant: merchant,
           amount: 100.0,
           customer_email: customer_email,
           customer_phone: customer_phone,
           status: 'reversed')
  end

  let(:charge) do
    create(:charge_transaction,
           merchant: merchant,
           parent_transaction: authorize,
           customer_email: customer_email,
           customer_phone: customer_phone,
           amount: 100.0,
           status: 'refunded')
  end

  let(:refund) do
    create(:refund_transaction,
           merchant: merchant,
           parent_transaction: charge,
           customer_email: customer_email,
           customer_phone: customer_phone,
           amount: 100.0,
           status: 'approved')
  end

  it 'displays transaction details' do
    login_as(merchant)
    visit merchant_transaction_path(merchant.id, refund.uuid)
    expect(page).to have_content('Transaction Details')
    expect(page).to have_content(refund.uuid)
    expect(page).to have_content('Refund')
    expect(page).to have_content('Approved')
    expect(page).to have_content('$100.00')
    expect(page).to have_content('client@example.com')
    expect(page).to have_content('1234567890')

    expect(page).to have_link(charge.uuid)
    expect(page).to have_link("Merchant 4")
  end

  it 'displays ancestry table' do
    login_as(merchant)
    refund.save
    visit merchant_transaction_path(merchant, refund.uuid)
    expect(page).to have_content('Ancestry')

    within('table') do
      rows = all('tbody tr')
      expect(rows.size).to eq(3)

      expect(rows[0]).to have_content('Authorize')
      expect(rows[0]).to have_content(authorize.uuid)
      expect(rows[0]).to have_content('Reversed')

      expect(rows[1]).to have_content('Charge')
      expect(rows[1]).to have_content(charge.uuid)
      expect(rows[1]).to have_content('Refunded')

      expect(rows[2]).to have_content('Refund')
      expect(rows[2]).to have_content(refund.uuid)
      expect(rows[2]).to have_content('Approved')
      expect(rows[2][:class]).to include('table-primary')
    end
  end

  it 'navigates to parent transaction via ancestry table' do
    login_as(merchant)
    visit merchant_transaction_path(merchant.id, refund.uuid)
    within('table') do
      rows = all('tbody tr')
      expect(rows.size).to eq(3)

      expect(rows[0])
        .to have_content("Authorize #{authorize.uuid} #{authorize.status.capitalize} #{number_to_currency(authorize.amount)}")

      expect(rows[1])
        .to have_content("Charge #{charge.uuid} #{charge.status.capitalize} #{number_to_currency(charge.amount)}")

      expect(rows[2])
        .to have_content("Refund #{refund.uuid} #{refund.status.capitalize} #{number_to_currency(refund.amount)}")

      rows[1].click
    end
    page.has_content?('Transaction Details')

    expect(page).to have_current_path(merchant_transaction_path(merchant.id, charge.uuid))
    expect(page).to have_content('Transaction Details')
    expect(page).to have_content(charge.uuid)
  end
end
