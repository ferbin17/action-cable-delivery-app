class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :name
      t.float :price, default: 0.0
      t.integer :merchant_id
      t.timestamps
    end
  end
end
