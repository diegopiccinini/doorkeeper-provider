require 'google_sign_in/identity'

class GoogleSignInController < ApplicationController
  def tokensignin
    @token_id= params[:token_id]
    GoogleSignIn::Identity.new @token_id

  end
end
