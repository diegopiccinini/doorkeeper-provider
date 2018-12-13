class WelcomeController < ApplicationController
  before_action :authenticate_user!

  def index
    sites = current_user.own_sites

    if session[:search]
      sites= sites.url_contains(session[:search])
    end

    applications = OauthApplicationsSite.enabled.applications_by_site_ids sites.ids

    filter_sites_by_applications_filter=false

    if session[:search_by_app]
      applications= applications.name_contains(session[:search_by_app])
      filter_sites_by_applications_filter=true
    end

    if session[:search_env]
      application_environment = ApplicationEnvironment.find_by name: session[:search_env]
      applications= applications.where(application_environment: application_environment)
      filter_sites_by_applications_filter=true
    end

    if filter_sites_by_applications_filter
      sites= OauthApplicationsSite.enabled.sites_by_application_ids(applications.ids).where(id: sites.ids)
    end

    @sites=sites.map do |site|
      site.oauth_applications.map do | application |
        { app_name: application.name , uri: app_uri(site.url), site_name: callback_name(site.url), environment: application.application_environment.name }
      end
    end.flatten

    @app_environments =ApplicationEnvironment.by_sites(sites).map { |a| a.name }
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

  def callback_name uri
    uri.end_with?('/callback') ? backend_name(uri) : frontend_name(uri)
  end

  def backend_name uri
    uri = uri[0..-('/callback'.length + 1)]
    name = URI(uri).host
    name.include?('.') ? name.split('.').first : name
  end

  def frontend_name uri
    frontend_uri_params=Base64.strict_decode64(encoded_frontend(uri)).split
    frontend_uri_params.join(' ') + ' [FRONTEND]'
  end

  def app_uri uri
    extra_param=''
    extra_param="/#{encoded_frontend(uri)}" unless uri.end_with?('/callback')
    uri[0..(uri.index('/callback') - 1 )] + extra_param
  end

  def encoded_frontend uri
    uri.split('/').last
  end
end
