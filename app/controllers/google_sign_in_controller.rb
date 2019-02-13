class GoogleSignInController < ApplicationController
  def tokensignin
    @token_id= params[:token_id]
  end
end
