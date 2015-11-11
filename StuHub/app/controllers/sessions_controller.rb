class SessionsController < ApplicationController
  skip_before_filter :require_login, except: [:destroy]
  before_filter :logged_out, except: [:destroy]

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        flash[:success] = 'Successfully logged in.'
        redirect_back_or home_url
      else
        flash[:warning] = "This account is not activated. Please check your email for the activation link."
        redirect_to login_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    if logged_in?
      if current_user.cas_login_active
        cas_endpoint = current_user.institution.cas_endpoint
        current_user.cas_login_active = false
        current_user.save
        log_out
        redirect_to "#{cas_endpoint}/appLogout?app=StuHub"
      else
        log_out
        flash[:success] = 'Successfully logged out.'
        redirect_to root_path
      end
    else
      flash[:warning] = 'You are not logged in.'
      redirect_to login_path
    end
  end

  private

  def logged_out
    if current_user
      flash[:warning] = "You cannot do that while logged in."
      redirect_to home_path
    end
  end
end
