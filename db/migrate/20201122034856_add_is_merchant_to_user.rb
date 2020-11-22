class AddIsMerchantToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_merchant, :boolean, default: false
  end
end
