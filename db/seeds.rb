# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

%w[Alice Bob Charlie].each do |name|
  User::Merchant.create!(name: name, description: Faker::Lorem.sentence, email: Faker::Internet.email, status: :active).save!
end

User::Admin.create!(name: "Admin", description: "Administrator", email: "admin@payment.com", status: :active)

User::Merchant.create!(name: "Inactive User", description: "Inactive user", email: "inactive@lol.com", status: :inactive)
