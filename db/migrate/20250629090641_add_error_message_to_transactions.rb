class AddErrorMessageToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :error_message, :text
  end
end
