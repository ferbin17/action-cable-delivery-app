class HomeController < ApplicationController

  # Root page (Home page)
  def index
    if @current_user.is_merchant
      # If user is merchant, show products of logined merchants in home page
      @products = @current_user.products
    else
      # If user is not merchant, show available products for ordeing in home page
      @order = Order.new
      @products = Product.all.group_by(&:user)
    end
  end
end
