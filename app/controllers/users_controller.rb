class UsersController < ApplicationController
  before_filter :set_user, except: [:index, :new, :create]
  before_filter :authorize, only: [:edit, :update, :destroy]

  def index
    @users = User.all
  end

  def new
    # don't let current_user see the sign up view
    if current_user
      redirect_to user_path(current_user)
    else
      @user = User.new
    end
  end

  def create
    # don't let current_user create new account
    if current_user
      redirect_to user_path(current_user)
    else
      @user = User.new(user_params)
      if @user.save
        session[:user_id] = @user.id
        flash[:notice] = "Successfully signed up."
        redirect_to user_path(@user)
      else
        flash[:error] = @user.errors.full_messages.join(", ")
        redirect_to signup_path
      end
    end
  end

  def show
  end

  def edit
    # don't let current_user see another user's edit view
    unless current_user == @user
      redirect_to user_path(current_user)
    end
  end

  def update
    # only let current_user update their own account
    if current_user == @user
      if @user.update_attributes(user_params)
        flash[:notice] = "Successfully updated profile."
        redirect_to user_path(@user)
      else
        flash[:error] = @user.errors.full_messages.join(", ")
        redirect_to edit_user_path(@user)
      end
    else
      redirect_to user_path(current_user)
    end
  end

  def destroy
    # only let current_user delete their own account
    if current_user == @user
      @user.destroy
      session[:user_id] = nil
      flash[:notice] = "Successfully deleted profile."
      redirect_to root_path
    else
      redirect_to user_path(current_user)
    end
  end

  private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end

    def set_user
      user_id = params[:id]
      @user = User.find_by_id(user_id)
    end

end