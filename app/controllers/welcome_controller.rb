class WelcomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @applications = current_user.applications.where(enabled: true)
    if session[:search]
      @applications= @applications.name_contains(session[:search])
    end
    if session[:search_env]
      @applications= @applications.name_ends(session[:search_env])
    end

  end

  def search
     session[:search]=nil
     session[:search_env]=nil

     session[:search]=params["search"] if params["search"]
     session[:search_env]=params["search_env"] if params["search_env"] and params["search_env"]!='ALL'

     redirect_to root_path

  end
end
