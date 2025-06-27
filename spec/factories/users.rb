FactoryBot.define do
  factory :user, class: 'User' do
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }
    email { Faker::Internet.email }
    status { Faker::Number.between(from: 0, to: 2) ? :active : :inactive }
  end

  factory :merchant, class: 'User::Merchant' do
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }
    email { Faker::Internet.email }
    status { Faker::Number.between(from: 0, to: 2) ? :active : :inactive }
    total_transaction_sum { 0.0 }
  end

  factory(:active_merchant, class: 'User::Merchant') do
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }
    email { Faker::Internet.email }
    status { :active }
    total_transaction_sum { 0.0 }
  end

  factory(:inactive_merchant, class: 'User::Merchant') do
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }
    email { Faker::Internet.email }
    status { :inactive }
    total_transaction_sum { 0.0 }
  end

  factory(:admin, class: 'User::Admin') do
    name { "Admin" }
    description { "Administrator" }
    email { "admin@payment.com" }
    status { :active }
  end
end
