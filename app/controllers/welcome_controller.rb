class WelcomeController < ApplicationController
  before_action :authenticate_user!

  def index
    applications = current_user.applications.where(enabled: true)
    if session[:search]
      applications= applications.name_contains(session[:search])
    end
    if session[:search_env]
      if session[:search_env]=='PRODUCTION'
        applications= applications.name_ends_or('PRODUCTION','WEB')
      else
        applications= applications.name_ends(session[:search_env])
      end
    end

    @applications = []
    applications.each do |a|
      a.redirect_uri.split.each do |uri|
        if session[:search].nil? or uri.split('.').first.include?session[:search]
          uri = uri[0..-('/callback'.length + 1)]
          @applications << { uri: uri, name: callback_name(uri), environment: a.name }
        end
      end
    end

  end

  def search
     session[:search]=nil
     session[:search_env]=nil

     session[:search]=params["search"].downcase if params["search"]
     session[:search_env]=params["search_env"] if params["search_env"] and params["search_env"]!='ALL'

     redirect_to root_path

  end

  private

  def callback_name(uri)
    name = URI(uri).host
    name.include?('.') ? name.split('.').first : name
  end
end
