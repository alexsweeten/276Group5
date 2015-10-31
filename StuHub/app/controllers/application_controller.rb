class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  before_filter :require_login
  before_filter :update_last_active

  private

  def require_login
    unless current_user
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  def update_last_active
    if current_user
      current_user.touch :last_active_at
    end
  end
end
