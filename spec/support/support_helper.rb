# frozen_string_literal: true

module SystemHelpers
  def login_as(user)
    visit new_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password

    find('input[name="commit"]').click
    page.has_content?('Logged in as')
  end

  def maybe_confirm
    begin
      page.driver.browser.switch_to.alert.accept
    rescue Selenium::WebDriver::Error::WebDriverError => e
      puts "No alert to confirm: #{e.message}"
    end
  end
end
