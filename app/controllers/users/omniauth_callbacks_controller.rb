class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user
      sign_in_and_redirect @user
    else
      flash[:error]= "Authentication failed filtering by domain #{ENV['CUSTOM_DOMAIN_FILTER']}! "
      redirect_to new_user_session_path
    end
  end
end
