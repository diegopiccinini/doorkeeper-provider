class WelcomeController < ApplicationController
  before_action :authenticate_user!

  def index
    applications = current_user.enabled_applications
    @app_environments= applications.map { |a| a.application_environment.name }
    @app_environments=@app_environments.uniq
    @app_environments << 'ALL'

    if session[:search]
      applications= applications.name_contains(session[:search])
    end
    if session[:search_env]
      application_environment = ApplicationEnvironment.find_by name: session[:search_env]
      applications= applications.where(application_environment: application_environment)
    end

    @applications = []
    applications.each do |a|
      a.redirect_uri.split.each do |uri|
        if session[:search].nil? or uri.split('.').first.include?session[:search] or a.name.include?session[:search].upcase
          @applications << { uri: app_uri(uri), name: callback_name(uri), environment: a.name }
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

  def callback_name uri
    uri.include?('logins/auth/bookingbug') ? backend_name(uri) : frontend_name(uri)
  end

  def backend_name uri
    uri = uri[0..-('/callback'.length + 1)]
    name = URI(uri).host
    name.include?('.') ? name.split('.').first : name
  end

  def frontend_name uri
    frontend_uri_params=Base64.strict_decode64(encoded_frontend(uri)).split
    frontend_uri_params.delete_at(1)
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
