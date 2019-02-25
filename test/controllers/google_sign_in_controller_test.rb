require 'test_helper'
require 'google_helper'

class GoogleSignInControllerTest < ActionController::TestCase

  include Devise::Test::ControllerHelpers

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
    assert_equal user.uid, payload[:sub]
    assert_equal user.provider, payload[:iss]
  end

  test "200 status response" do
    assert_equal 200, @response.status
  end

  test "body has a redirect_uri" do
    body=JSON.parse @response.body
    assert_match root_path, body['redirect_uri']
  end

  test "has a current user" do
    assert_equal assigns(:user).id, @controller.current_user.id
  end

  test "user exists" do
    User.find_by( email: payload[:email]).delete
    user=users(:one)
    user.email=payload[:email]
    user.expire_at=6.months.from_now
    user.save validate: false

    GoogleToken.where( token: @token).delete_all

    post :tokensignin , idtoken: @token
    user.reload
    assert_equal user.email, payload[:email]
    assert_equal user.uid, payload[:sub]
    assert_equal user.provider, payload[:iss]
  end
end
