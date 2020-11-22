class HomeController < ApplicationController

  def index
    if @current_user.is_merchant
      @products = @current_user.products
    else
      @order = Order.new
      @products = Product.all.group_by(&:user)
    end
  end
end
