# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User login', type: :system do
  let!(:user) { create(:admin) }

  context 'as admin' do
    it 'logs in successfully' do
      visit new_session_path

      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      find('input[name="commit"]').click

      expect(page).to have_current_path(merchant_index_path)
      expect(page).to have_content("Logout")
      click_button 'Logout'
      expect(page).to have_current_path(new_session_path)
      expect(page).to have_content("Login")
    end

    it 'shows error on invalid login' do
      visit new_session_path

      fill_in 'Email', with: 'wrong@example.com'
      fill_in 'Password', with: 'nope'
      find('input[name="commit"]').click

      expect(page).to have_content('Try another email address or password')
    end
  end

  context 'as merchant' do
    let!(:merchant) { create(:merchant) }

    it 'logs in successfully' do
      visit new_session_path

      fill_in 'Email', with: merchant.email
      fill_in 'Password', with: merchant.password
      find('input[name="commit"]').click

      expect(page).to have_current_path(merchant_path(merchant))
      expect(page).to have_content("Logout")

      click_button 'Logout'
      expect(page).to have_current_path(new_session_path)
      expect(page).to have_content("Login")
    end
  end
end
