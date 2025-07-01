require 'faker'

puts "Seeding users and transactions..."

admin = User::Admin.create!(
  email: "admin@payment.com",
  password: "Password@123",
  name: "Admin User",
  status: "active"
)

puts "Admin created: #{admin.email}"

3.times do |i|
  merchant = User::Merchant.create!(
    email: "merchant#{i + 1}@payment.com",
    password: "Password@123",
    status: "active",
    name: "Merchant #{i + 1}",
  )

  puts "Merchant created: #{merchant.email}"

  # Create Authorize
  auth_result = Transaction::Operation::Authorize.call(
    merchant: merchant,
    params: {
      amount: 100.00,
      customer_email: Faker::Internet.email,
      customer_phone: Faker::PhoneNumber.cell_phone
    }
  )

  if auth_result.success?
    authorize_tx = auth_result[:model]
    puts "  Authorize #{authorize_tx.uuid} created"
  else
    puts "  Authorize failed: #{auth_result[:errors]}"
    next
  end

  # Create Charge
  charge_result = Transaction::Operation::Charge.call(
    merchant: merchant,
    params: {
      amount: authorize_tx.amount,
      parent_transaction_uuid: authorize_tx.uuid,
      customer_email: Faker::Internet.email,
      customer_phone: Faker::PhoneNumber.cell_phone
    }
  )

  if charge_result.success?
    charge_tx = charge_result[:model]
    puts "  Charge #{charge_tx.uuid} created"
  else
    puts "  Charge failed: #{charge_result[:errors]}"
    next
  end

  # Create Refund
  refund_result = Transaction::Operation::Refund.call(
    merchant: merchant,
    params: {
      amount: charge_tx.amount,
      parent_transaction_uuid: charge_tx.uuid,
      customer_email: Faker::Internet.email,
      customer_phone: Faker::PhoneNumber.cell_phone
    }
  )

  if refund_result.success?
    refund_tx = refund_result[:model]
    puts "  Refund #{refund_tx.uuid} created"
  else
    puts "  Refund failed: #{refund_result[:errors]}"
  end

  # Create Reversal
  reversal_result = Transaction::Operation::Reversal.call(
    merchant: merchant,
    params: {
      parent_transaction_uuid: authorize_tx.uuid,
      amount: nil,
      customer_email: Faker::Internet.email,
      customer_phone: Faker::PhoneNumber.cell_phone
    }
  )

  if reversal_result.success?
    puts "  Reversal #{reversal_result[:model].uuid} created"
  else
    puts "  Reversal failed: #{reversal_result[:errors]}"
  end
end

puts "Seeding complete!"
