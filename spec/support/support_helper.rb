# frozen_string_literal: true

module SystemHelpers
  def login_as(user)
    visit new_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password

    find('input[name="commit"]').click
  end
end
