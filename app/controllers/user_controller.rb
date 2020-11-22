class UserController < ApplicationController
  skip_before_action :login_required, only: [:login, :sign_up]
  before_action :redirect_to_root, only: [:login, :sign_up]

  def login
    @user = User.new
    if request.post?
      @user = User.new(user_params)
      if @user.authenticate
        user = User.active.where("email_id = ?", @user.email_id).first
        user.update(sign_in_count: user.sign_in_count.to_i + 1, dont_validate_password: false)
        session[:user_id] = cookies.signed[:user_id] = user.id
        reset_flash_message
        session[:just_logined] = true
        redirect_to (session[:back_path].present? ? session.delete(:back_path) : root_path)
      else
        reset_flash_message
        flash[:danger] = t(:wrong_credentials)
        redirect_to action: :login
      end
    end
  end
  
  def sign_up
    reset_flash_message
    @user = User.new
    if request.post?
      @user = User.new(user_params) 
      check_user_exists = User.find_by_email_id(@user.email_id).present?
      unless check_user_exists
        if @user.save
          session[:user_id] = cookies.signed[:user_id] = @user.id
          redirect_to :root
        else
          render action: :sign_up
        end
      else
        flash[:danger] = "#{t(:account_exist)}. <br>#{view_context.link_to t(:click_here_to_login), login_user_index_path} or #{view_context.link_to t(:click_hereh_to_reset_password), forgot_password_user_index_path}"
        redirect_to action: :sign_up
      end
    end
  end

  def logout
    reset_session
    redirect_to :root
  end
  
  def check_unattended_orders
  end
  
  private

    def user_params
      params.require(:user).permit(:password, :confirm_password, :email_id, :is_merchant)
    end
    
    def reset_session
      session[:user_id] = cookies.signed[:user_id] = nil
    end
    
    def redirect_to_root
      if session[:user_id].present?
        redirect_to :root
      end
    end
end
