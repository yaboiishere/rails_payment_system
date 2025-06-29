FactoryBot.define do
  factory :user, class: 'User' do
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }
    email { Faker::Internet.email }
    status { Faker::Number.between(from: 0, to: 2) ? :active : :inactive }
    password { 'password' }
  end

  factory :merchant, class: 'User::Merchant', parent: :user do
  end

  factory(:active_merchant, class: 'User::Merchant', parent: :user) do
    status { :active }
  end

  factory(:inactive_merchant, class: 'User::Merchant', parent: :user) do
    status { :inactive }
  end

  factory(:admin, class: 'User::Admin') do
    name { "Admin" }
    description { "Administrator" }
    email { "admin@payment.com" }
    status { :active }
    password { 'password' }
  end
end
