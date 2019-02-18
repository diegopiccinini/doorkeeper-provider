require 'google_sign_in/validator'

module LoginHelper

  def token_login
    unless Rails.env=='production'
      user=User.first
      GoogleSignIn::Validator.user_token user
    end
  end

end
