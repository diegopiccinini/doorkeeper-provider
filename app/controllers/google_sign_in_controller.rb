require 'google_sign_in/identity'

class GoogleSignInController < ApplicationController

  def tokensignin
    @user = User.from_identity identity

    if @user && !@user.disabled && !@user.expired?
      sign_in_and_redirect @user
    else
      flash[:error]= "Authentication has failed! "
      flash[:error] << "Your user is disabled in this server" if @user && @user.disabled
      flash[:error] << "Your user is expired, please contact the Engineering Team." if @user && @user.expired?
      redirect_to login_path
    end

  rescue => error
    @message=error.message
  end

  private

  def identity
    GoogleSignIn::Identity.new params[:idtoken]
  end
end
