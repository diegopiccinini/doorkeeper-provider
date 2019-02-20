require 'google_sign_in/identity'

class GoogleSignInController < ApplicationController

  skip_before_filter :verify_authenticity_token

  DOMAIN_NOT_INCLUDED_ERROR="The domain %s is not allowed to login in the Central Auth."
  IDTOKEN_NOT_PRESENT_ERROR="idtoken param is not present."
  USER_DISABLED_ERROR="The user %s is disabled."
  USER_EXPIRED_ERROR="Your user had expired at %s."
  COULD_NOT_CREATE_USER_ERROR="Could not create or find a user with this identity %s."

  def tokensignin
    idtoken
    user
    check_user
    sign_in @user
    render :json  => { status: 200, redirect_uri: root_path }
  rescue => error
    render :json => { status: 422, error: error.message }, status: 422
  end

  private

  def idtoken
    raise IDTOKEN_NOT_PRESENT_ERROR unless params.has_key?(:idtoken)
  end

  def identity
    @identity||=GoogleSignIn::Identity.new params[:idtoken]
  end

  def user
    raise DOMAIN_NOT_INCLUDED_ERROR % identity.domain unless ENV['CUSTOM_DOMAIN_FILTER'].split.include?(identity.domain)
    @user = User.from_identity identity
  end

  def check_user
    raise COULD_NOT_CREATE_USER_ERROR % identity.inspect if @user.nil?
    raise USER_DISABLED_ERROR % @user.email if @user.disabled
    raise USER_EXPIRED_ERROR % @user.expire_at.to_s if @user.expired?
  end
end
