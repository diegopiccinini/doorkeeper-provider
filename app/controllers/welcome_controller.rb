class WelcomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @applications = current_user.oauth_applications
  end
end
