class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.float :total_price
      t.boolean :read_by_user, default: true
      t.boolean :read_by_merchant, default: false
      t.integer :status
      t.integer :alert_stage, default: 0
      t.timestamps
    end
  end
end
