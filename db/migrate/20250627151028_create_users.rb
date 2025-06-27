class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :description
      t.string :email
      t.integer :status
      t.decimal :total_transaction_sum
      t.string :type

      t.timestamps
    end
  end
end
