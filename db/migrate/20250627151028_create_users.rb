class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :description
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :status
      t.decimal :total_transaction_sum
      t.string :type

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
