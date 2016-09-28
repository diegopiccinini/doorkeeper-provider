class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user
      sign_in_and_redirect @user
    else
      redirect_to root_path, flash: { error: "Authentication failed!" }
    end
  end
end
