class WelcomeController < ApplicationController

  before_action :authenticate_user!, except: [:login]

  def index

    sites=current_user.enabled_sites

    if session[:search]
      sites= sites.url_contains(session[:search])
    end

    if session[:search_by_app]
      sites= sites.where("oauth_applications.name LIKE ?","%#{session[:search_by_app]}%")
    end

    if session[:search_env]
      sites= sites.where('application_environments.name': session[:search_env])
    end

    @total_sites=sites.count

    @sites=sites.paginate(:page => params[:page], :per_page => limit)
    @app_environments =sites.group("application_environments.name").count('sites.id').keys
    @app_environments << 'ALL'
  end

  def search
    session[:search]=nil
    session[:search_by_app]=nil
    session[:search_env]=nil

    session[:search]=params["search"].downcase.strip if params["search"] and !params["search"].strip.empty?
    session[:search_by_app]=params["search_by_app"].upcase.strip if params["search_by_app"] and !params["search_by_app"].strip.empty?
    session[:search_env]=params["search_env"] if params["search_env"] and params["search_env"]!='ALL'

    redirect_to root_path

  end

  private

  def limit
    ENV['SITES_LIST_LIMIT'] || 10
  end

end
