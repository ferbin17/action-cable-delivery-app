class Order < ApplicationRecord
  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products
  belongs_to :user
  accepts_nested_attributes_for :order_products
  before_create :set_price, if: Proc.new{|x| x.total_price.nil?}
  after_create :set_merchant, if: Proc.new{|x| x.merchant_id.nil?}
  before_create :validate_products, if: Proc.new{|x| x.order_products.present?}
  validate :validate_status_change, if: Proc.new{|x| x.status_changed?}
  validate :validate_products, on: :create
  
  STATUS = {0 => "Cancelled", 1 => "Rejected", 2 => "Accepted",
    3 => "Food Processing", 4 => "On the way", 5 => "Delivered"}
  STAGES_AFTER_ACCEPT = {1 => "Rejected", 2 => "Process Food", 3 => "On the way", 4 => "Delivered"}
  
  def order_price
    self.order_products.collect(&:product).sum(&:price)
  end
  
  def find_merchant
    self.order_products.collect(&:product).collect(&:user).uniq.first
  end
  
  def merchant
    User.find_by_id(self.merchant_id)
  end
  
  private
    def set_price
      self.total_price = self.order_price
    end
    
    def set_merchant
      self.update(merchant_id: self.find_merchant.try(:id))
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
    
    def validate_products
      merchants = self.order_products.collect(&:product).collect(&:user).uniq
      self.errors.add(:base, "Select product from only one merchant at a time") if merchants.count > 1
    end
end
