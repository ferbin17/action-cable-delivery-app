class OrdersController < ApplicationController
  
  # Order home/index
  def index
    # Shows orders of either user or merchant
    @orders = (@current_user.is_merchant ? @current_user.merchant_orders : @current_user.orders).order("id desc")
  end

  def create
    # Resets old flash messages if any
    reset_flash_message
    if order_params[:order_products_attributes].present?
      # Store order details in session for confirmation if valid
      @order = @current_user.orders.build(order_params)
      session[:order] = order_params if @order.valid?
    elsif params[:confirmed]
      # Creates order entry if valid and confirmed
      @order = @current_user.orders.build(session[:order])
      if @order.save
        session[:order] = nil
        flash[:success] = "Order Placed"
        # Broadcast order details and order alert (html partial) to the concerned merchant channel 
        ActionCable.server.broadcast "merchant_channel_#{@order.merchant.try(:id)}", content: @order.id,
            html: render_to_string(partial: 'order_card', locals: {order: @order, user: @order.merchant, color: ""}),
            alert: render_to_string(partial: 'order_alert', locals: {order: @order, user: @order.merchant})
      end
    else
      # Shows flash message if not products are selected
      flash[:danger] = "Select atleast one Product to order"
    end
    respond_to do |format|
      format.js
    end
  end
  
  def show
    # Show page, not implemented or needed as of now
    find_order
  end
  
  def update_order
    # Update order status by either user or merchant
    find_order
    @status_changed = false
    if @current_user.is_merchant
      # update if merchant
      if params[:stage]
        if @order.update(status: params[:stage])
          @status_changed = true
          # Broadcast order details and order alert (html partial) to concerned user
          ActionCable.server.broadcast "user_channel_#{@order.user_id}", content: @order.id,
              html: render_to_string(partial: 'order_card', locals: {order: @order, user: @order.user, color: ""}),
              alert: render_to_string(partial: 'order_alert', locals: {order: @order, user: @order.user})
        end
      end
    else
      # Update if user (not merchant)
      if params[:stage] && params[:stage] == "0"
        if @order.update(status: 0)
          @status_changed = true
          # Broadcast order details and order alert (html partial) to concerned merchant
          ActionCable.server.broadcast "merchant_channel_#{@order.merchant.try(:id)}", content: @order.id,
              html: render_to_string(partial: 'order_card', locals: {order: @order, user: @order.merchant, color: ""}),
              alert: render_to_string(partial: 'order_alert', locals: {order: @order, user: @order.merchant})
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end

  private
    # Fetches order params if any
    def order_params
      params.fetch(:order, {}).permit(order_products_attributes:[:product_id])
    end
    
    # Find order and change read status. Also redirect to order index if order not found
    def find_order
      @order = Order.find_by_id(params[:id])
      unless @order.present?
        flash[:warning] = "Order not found"
        redirect_to action: :index
      end
      @order.update(read_by_merchant: true) if @current_user.is_merchant && !@order.read_by_merchant
    end
end
