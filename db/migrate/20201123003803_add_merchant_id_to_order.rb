class AddMerchantIdToOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :merchant_id, :integer
  end
end
