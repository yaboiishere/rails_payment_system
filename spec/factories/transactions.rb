FactoryBot.define do
  factory :transaction do
    uuid { SecureRandom.uuid }
    amount { 100.00 }
    status { "approved" }
    customer_email { Faker::Internet.email }
    customer_phone { Faker::PhoneNumber.cell_phone }
    association :merchant, factory: :merchant
  end

  factory :authorize_transaction, class: 'Transaction::Authorize', parent: :transaction do
    parent_transaction_id { nil } # Authorize transactions do not have a parent
  end
  factory :charge_transaction, class: 'Transaction::Charge', parent: :transaction do
    association :parent_transaction, factory: :authorize_transaction
  end
  factory :refund_transaction, class: 'Transaction::Refund', parent: :transaction do
    association :parent_transaction, factory: :charge_transaction
  end
  factory :reversal_transaction, class: 'Transaction::Reversal', parent: :transaction do
    amount { nil }
    association :parent_transaction, factory: :authorize_transaction
  end
end
