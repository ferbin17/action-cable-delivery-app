class Product < ApplicationRecord
  belongs_to :user, foreign_key: :merchant_id
  has_many :order_products, dependent: :destroy
  has_many :orders, through: :order_products
end
