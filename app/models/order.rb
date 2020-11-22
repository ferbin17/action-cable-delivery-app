class Order < ApplicationRecord
  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products
  belongs_to :user
  accepts_nested_attributes_for :order_products
  before_save :set_price, if: Proc.new{|x| x.total_price.nil?}
  before_save :validate_status_change, if: Proc.new{|x| x.status_changed?}
  
  STATUS = {0 => "Cancelled", 1 => "Rejected", 2 => "Accepted",
    3 => "Food Processing", 4 => "On the way", 5 => "Delivered"}
  STAGES_AFTER_ACCEPT = {1 => "Rejected", 2 => "Process Food", 3 => "On the way", 4 => "Delivered"}
  
  def order_price
    self.order_products.collect(&:product).sum(&:price)
  end
  
  def order_merchants
    self.products.collect(&:user).uniq
  end
  
  private
    def set_price
      self.update(total_price: self.order_price)
    end
    
    def validate_status_change
      case self.status_was
      when 0, 1, 5
        self.errors.add(:status, "Not valid")
      when 2
        self.errors.add(:status, "Not valid") if self.status != 1 && self.status != 3
      when 3
        self.errors.add(:status, "Not valid") if self.status != 1 && self.status != 4
      when 4
        self.errors.add(:status, "Not valid") if self.status != 1 && self.status != 5
      else    
      end
    end
end
