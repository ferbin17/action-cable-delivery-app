class User < ApplicationRecord  
  attr_accessor :password, :confirm_password, :dont_validate_password
  validates_presence_of :email_id
  validates_presence_of :password, if: Proc.new{|user| user.dont_validate_password != false}
  validates_presence_of :confirm_password, if: Proc.new{|user| user.new_record?}
  validate :password_match, if: Proc.new{|user| user.password.present?}
  validates :email_id, uniqueness: { scope: :is_active,
      message: "can have only one active per time." }, if: Proc.new{|user| user.new_record?}
  has_many :orders
  has_many :products, foreign_key: :merchant_id
  before_save :hash_password, if: Proc.new{|user| user.dont_validate_password != false}
  scope :active, -> { where(is_active: true) }
  
  
  def authenticate
    user = User.active.where("email_id = ?", self.email_id).first
    if user.present?
      return user.hashed_password == Digest::SHA1.hexdigest(user.password_salt.to_s + self.password)
    end
    return false
  end
  
  def self.minimum_password_length
    false
  end
  
  private
  
    def password_match
      if password != confirm_password
        errors.add(:password, "doesn't match")
      end
    end
    
    def hash_password
      self.password_salt =  SecureRandom.base64(8) if self.password_salt == nil
      self.hashed_password = Digest::SHA1.hexdigest(self.password_salt + self.password)
    end
end
