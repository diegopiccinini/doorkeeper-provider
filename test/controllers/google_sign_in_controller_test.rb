require 'test_helper'
require 'google_helper'
require 'google_sign_in/validator'

class GoogleSignInControllerTest < ActionController::TestCase

  setup do
    @token=token
  end

  def validator
    GoogleSignIn::Validator
  end

  def payload
    {
      exp: validator.exp.to_i,
      iss: validator.iss,
      aud: validator.aud,
      cid: validator.client_id,
      user_id: '12345',
      email: 'test@gmail.com',
      provider_id: 'google.com',
      verified: true
    }
  end

  def token
    JWT.encode(payload, validator.key, 'RS256')
  end

  test "tokensignin" do
    post :tokensignin , idtoken: @token
    assert_equal @token, assigns(:token_id)
  end
end
