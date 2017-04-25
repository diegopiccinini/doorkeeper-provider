class WelcomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @applications = current_user.applications.where(enabled: true)
  end
end
