require 'test_helper'
require 'google_helper'

class GoogleSignInControllerErrorsTest < ActionController::TestCase

  tests GoogleSignInController

  include Devise::Test::ControllerHelpers

  def body
    JSON.parse @response.body
  end

  test "whithout token" do
    post :tokensignin
    assert_equal 422, @response.status
    assert_match body['error'], GoogleSignInController::IDTOKEN_NOT_PRESENT_ERROR
  end

  test "bad token" do
    post :tokensignin, idtoken: 'fake token'
    assert_equal 422, @response.status
    assert body.has_key?('error')
  end

  test "user disabled" do
    user=users(:one)
    user.email=payload[:email]
    user.disabled=true
    user.save validate: false
    post :tokensignin, idtoken: token
    assert_equal user.email, payload[:email]
    assert_equal 422, @response.status
    assert_match body['error'], GoogleSignInController::USER_DISABLED_ERROR % user.email
  end

  test "user expired" do
    user=users(:one)
    user.email=payload[:email]
    user.expire_at=20.days.ago
    user.save validate: false
    post :tokensignin, idtoken: token
    assert_equal user.email, payload[:email]
    assert_equal 422, @response.status
    assert_match body['error'], GoogleSignInController::USER_EXPIRED_ERROR % user.expire_at.to_s
  end

  test "user invalid domain" do
    user=users(:one)
    user.email='peter@baddomain.com'
    user.expire_at=20.day.from_now
    user.save validate: false
    user_token=GoogleSignIn::Validator.user_token user

    post :tokensignin, idtoken: user_token
    assert_equal 422, @response.status
    assert_match body['error'], GoogleSignInController::DOMAIN_NOT_INCLUDED_ERROR % 'baddomain.com'
  end
end
