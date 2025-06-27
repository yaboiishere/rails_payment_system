class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.string :uuid
      t.decimal :amount
      t.integer :status
      t.string :customer_email
      t.string :customer_phone
      t.references :merchant, null: false, foreign_key: { to_table: :users }
      t.references :parent_transaction, foreign_key: { to_table: :transactions }

      t.string :type

      t.timestamps
    end
  end
end
