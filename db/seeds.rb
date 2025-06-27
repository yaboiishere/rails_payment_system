# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear old data
Transaction.delete_all
User.delete_all

puts "Seeding users..."

User::Admin.create!(
  name: "Alice Admin",
  email: "admin@example.com",
  status: :active
)

merchant1 = User::Merchant.create!(
  name: "Tech Store",
  email: "merchant1@example.com",
  status: :active,
  total_transaction_sum: 0
)

User::Merchant.create!(
  name: "Coffee Shop",
  email: "merchant2@example.com",
  status: :inactive,
  total_transaction_sum: 0
)

merchant3 = User::Merchant.create!(
  name: "Gaming Hub",
  email: "merchant3@example.com",
  status: :active,
  total_transaction_sum: 0
)

# Authorize for merchant1
auth_tx = Transaction::Authorize.create!(
  merchant: merchant1,
  amount: 100.00,
  status: "approved",
  customer_email: "john@example.com",
  customer_phone: "1234567890"
)

# Charge referencing the authorize
charge_tx = Transaction::Charge.create!(
  merchant: merchant1,
  amount: 100.00,
  status: "approved",
  parent_transaction: auth_tx,
  customer_email: "john@example.com",
  customer_phone: "1234567890"
)

# Refund referencing the charge
Transaction::Refund.create!(
  merchant: merchant1,
  amount: 100.00,
  status: "refunded",
  parent_transaction: charge_tx,
  customer_email: "john@example.com",
  customer_phone: "1234567890"
)

# Reversal referencing another auth
auth2 = Transaction::Authorize.create!(
  merchant: merchant3,
  amount: 50.00,
  status: "approved",
  customer_email: "jane@example.com",
  customer_phone: "5551234567"
)

Transaction::Reversal.create!(
  merchant: merchant3,
  status: "reversed",
  parent_transaction: auth2,
  customer_email: "jane@example.com",
  customer_phone: "5551234567"
)

puts "Seeding complete!"
