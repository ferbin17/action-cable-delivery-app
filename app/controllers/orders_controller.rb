class OrdersController < ApplicationController
  
  def index
    @orders = (@current_user.is_merchant ? @current_user.products.collect(&:orders).first : @current_user.orders).order("id desc")
  end

  def create
    reset_flash_message
    if order_params[:order_products_attributes].present?
      @order = @current_user.orders.build(order_params)
      session[:order] = order_params
    elsif params[:confirmed]
      @order = @current_user.orders.build(session[:order])
      if @order.save
        session[:order] = nil
        flash[:success] = "Order Placed"
        @order.order_merchants.each do |merchant|
          ActionCable.server.broadcast "merchant_channel_#{merchant.id}", content: @order.id,
              html: render_to_string(partial: 'order_card', locals: {order: @order, user: merchant, color: ""}),
              alert: render_to_string(partial: 'order_alert', locals: {order: @order})
        end
      end
    else
      flash[:danger] = "Select atleast one Product to order"
    end
    respond_to do |format|
      format.js
    end
  end
  
  def show
    find_order
  end
  
  def update_order
    find_order
    @status_changed = false
    if @current_user.is_merchant
      if params[:stage]
        if @order.update(status: params[:stage])
          @status_changed = true
          ActionCable.server.broadcast "user_channel_#{@order.user_id}", content: @order.id,
              html: render_to_string(partial: 'order_card', locals: {order: @order, user: @order.user, color: ""}),
              alert: render_to_string(partial: 'order_alert', locals: {order: @order})
        end
      end
    else
      if params[:stage] && params[:stage] == "0"
        if @order.update(status: 0)
          @status_changed = true
          merchant = @order.order_merchants.uniq.first
          ActionCable.server.broadcast "merchant_channel_#{merchant.id}", content: @order.id,
              html: render_to_string(partial: 'order_card', locals: {order: @order, user: merchant, color: ""}),
              alert: render_to_string(partial: 'order_alert', locals: {order: @order})
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end

  private
    def order_params
      params.fetch(:order, {}).permit(order_products_attributes:[:product_id])
    end
    
    def find_order
      @order = Order.find_by_id(params[:id])
      unless @order.present?
        flash[:warning] = "Order not found"
        redirect_to action: :index
      end
      @order.update(read_by_merchant: true) if @current_user.is_merchant && !@order.read_by_merchant
    end
end
