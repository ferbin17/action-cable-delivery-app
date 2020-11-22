class AddSingnedOutAtToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :last_signed_out_at, :datetime
  end
end
