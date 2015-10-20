class UsersController < ApplicationController
  skip_before_filter :require_login, only: [:new, :create]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  ## Use 'find' method to show certain user
  def show
    @user = User.find(params[:id])
  end

  def index
    @userscount = User.all.count
    @users = User.paginate(page: params[:page], per_page: 25).order('created_at ASC')
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      flash.now[:danger] = "Please check your registration for errors."
      # This really should get @user.errors and list them.
      render 'new'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User Deleted"
    redirect_to users_url
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile Updated"
      redirect_to @user
      # update succeed
    else
      render 'edit'
    end
  end

  private

   def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
   end

    # Filters
    # ensure logged in
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # ensure correct user
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless (current_user?(@user) or current_user.admin?)
    end

     # make sure admin
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
