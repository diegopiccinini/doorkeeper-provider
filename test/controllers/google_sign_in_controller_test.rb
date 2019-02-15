require 'test_helper'
require 'google_helper'

class GoogleSignInControllerTest < ActionController::TestCase

  setup do
    @token=token
    post :tokensignin , idtoken: @token
  end

  test "#identity" do
    i = @controller.send( :identity )
    assert_equal i.email_address, payload[:email]
  end

  test "#tokensignin" do
    user=assigns(:user)
    assert_equal user.email, payload[:email]
  end
end
