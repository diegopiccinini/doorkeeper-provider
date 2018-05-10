class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user && !@user.disabled && !@user.expired?
      sign_in_and_redirect @user
    else
      flash[:error]= "Authentication has failed! "
      flash[:error] << "Your user is disabled in this server" if @user && @user.disabled
      flash[:error] << "Your user is expired, please contact the Engineering Team." if @user && @user.expired?
      redirect_to new_user_session_path
    end
  end
end
