class SessionsController < ApplicationController

  def new
    # don't let current_user see the log in view
    if current_user
      redirect_to user_path(current_user)
    end
  end

  def create
    @user = User.find_by_email(user_params[:email])
    # If the user exists AND the password entered is correct.
    if @user && @user.authenticate(user_params[:password])
      # Save the user id inside the browser cookie. This is how we keep the user 
      # logged in when they navigate around our website.
      session[:user_id] = @user.id
      flash[:notice] = "Successfully logged in."
      redirect_to user_path(@user)
    else
      flash[:error] = "Incorrect email or password."
      redirect_to login_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Successfully logged out."
    redirect_to root_path
  end

  private

    def user_params
      params.require(:user).permit(:email, :password)
    end

end