# frozen_string_literal: true

require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'Merchant management', type: :system do
  let!(:admin) { create(:admin) }
  let!(:merchant) { create(:merchant) }
  let(:transaction) { create(:authorize_transaction, merchant: merchant) }

  context 'as admin' do
    it 'shows a list of merchants' do
      login_as(admin)
      visit merchant_index_path

      expect(page).to have_content('Merchants')
      expect(page).to have_content(merchant.email)
    end

    it 'allows editing a merchant' do
      login_as(admin)
      visit merchant_path(merchant)
      expect(page).to have_content(merchant.name)
      expect(page).to have_content(merchant.email)
      expect(page).to have_content(merchant.status.titleize)
      expect(page).to have_link('Edit')
      click_link 'Edit'

      fill_in 'Email', with: 'updated@email.com'
      fill_in 'Name', with: 'Updated Name'
      select 'Inactive', from: 'Status'
      find('input[name="commit"]').click

      expect(page).to have_content('Merchant updated successfully.')
      expect(page).to have_content('Updated Name')
      expect(page).to have_content('updated@email.com')
      expect(page).to have_content('Inactive')
      expect(merchant.reload.email).to eq('updated@email.com')
    end

    it 'prevents deleting a merchant with transactions' do
      login_as(admin)
      transaction.save!

      visit merchant_index_path

      expect(page).to have_button('Delete')
      click_button 'Delete'
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content('Cannot delete record because dependent transactions exist')
    end

    it 'allows deleting a merchant without transactions' do
      login_as(admin)
      visit merchant_index_path

      expect(page).to have_button('Delete')
      click_button 'Delete'
      page.driver.browser.switch_to.alert.accept

      expect(page).to have_current_path(merchant_index_path)
      expect(page).to have_content('Merchant deleted successfully.')
      expect(User::Merchant.exists?(merchant.id)).to be_falsey
    end

    it 'shows merchant details when no transactions' do
      login_as(admin)
      merchant.description = nil
      merchant.save!
      visit merchant_path(merchant)

      expect(page).to have_content("Merchant: #{merchant.name}")
      expect(page).to have_content('Description')
      expect(page).to have_content('No description provided')
      expect(page).to have_content(merchant.status.titleize)
      expect(page).to have_content('All time transactions sum')
      expect(page).to have_link('Edit')
      expect(page).to have_button('Delete')
      expect(page).to have_link('Back')
      expect(page).to have_content('No transactions for this merchant in the last hour.')
    end
  end

  context 'as merchant' do
    it 'shows own merchant details when no transactions' do
      Transaction.delete_all
      login_as(merchant)
      visit merchant_path(merchant)

      expect(page).to have_content("Merchant: #{merchant.name}")
      expect(page).to have_content(merchant.email)
      expect(page).to have_content(merchant.status.titleize)
      expect(page).to have_content('Description')
      expect(page).to have_content(merchant.description)
      expect(page).to have_content('All time transactions sum')
      expect(page).to have_content('Transactions count in the last hour')
      expect(page).to have_link('Edit')
      expect(page).not_to have_button('Delete')
      expect(page).not_to have_link('Back')

      expect(page).to have_content('No transactions for this merchant in the last hour.')
    end

    let(:authorize) { create(:authorize_transaction, merchant: merchant) }
    let(:charge) { create(:charge_transaction, merchant: merchant, parent_transaction: authorize) }
    let(:refund) { create(:refund_transaction, merchant: merchant, parent_transaction: charge) }
    let(:error_charge) { build(:charge_transaction, merchant: merchant, parent_transaction_id: refund.id, status: 'error') }
    let(:reversal) { create(:reversal_transaction, merchant: merchant, parent_transaction: authorize) }
    it 'shows own merchant details with transactions' do
      login_as(merchant)
      # These are created here to ensure the order of creation is correct
      authorize.save!
      charge.save!
      refund.save!
      error_charge.save!(validate: false)
      reversal.save!
      visit merchant_path(merchant)

      expect(page).to have_content("Merchant: #{merchant.name}")
      expect(page).to have_content(merchant.email)
      expect(page).to have_content(merchant.status.titleize)
      expect(page).to have_content('Description')
      expect(page).to have_content(merchant.description)
      expect(page).to have_content('All time transactions sum')
      expect(page).to have_content('Transactions count in the last hour')
      expect(page).to have_link('Edit')
      expect(page).not_to have_button('Delete')
      expect(page).not_to have_link('Back')

      # has table with transactions
      expect(page).to have_content('Transaction UUID')
      expect(page).to have_content('Type')
      expect(page).to have_content('Amount')
      expect(page).to have_content('Status')
      expect(page).to have_content('Created At')
      expect(page).to have_content('Parent')

      within('tbody') do
        rows = all('tbody>tr')
        expect(rows.size).to eq(5) # authorize, charge, refund, error_charge, reversal

        expect(rows[0])
          .to have_content("#{reversal.uuid} Reversal - #{reversal.status.capitalize}")

        expect(rows[0]).to have_content(authorize.uuid)

        expect(rows[1])
          .to have_content("#{error_charge.uuid} Charge #{number_to_currency(error_charge.amount)} Error")

        expect(rows[2])
          .to have_content("#{refund.uuid} Refund #{number_to_currency(refund.amount)} #{refund.status.capitalize}")
        expect(rows[2])
          .to have_content(charge.uuid)

        expect(rows[3])
          .to have_content("#{charge.uuid} Charge #{number_to_currency(charge.amount)} #{charge.status.capitalize}")
        expect(rows[3])
          .to have_content(authorize.uuid)

        expect(rows[4])
          .to have_content("#{authorize.uuid} Authorize #{number_to_currency(authorize.amount)} #{authorize.status.capitalize}")

        rows[0].click

        expect(page).to have_current_path(merchant_transaction_path(merchant, reversal.uuid))
      end
    end
  end
end
