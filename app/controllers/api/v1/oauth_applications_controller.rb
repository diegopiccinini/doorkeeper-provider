class Api::V1::OauthApplicationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authorized
  before_action :set_application , only: [:show, :update]
  respond_to :json
  layout false

  def index

    sites= OauthApplication.enabled.map do |a|
      a.redirect_uri.split.map { |site| [ site, a.name ] }
    end

    sites.flatten!(1)
    response_data = { type: :sites_enabled_list , count: sites.count, sites:  sites }

    render json: response_data

  end

  def show
    render json: @oauth_application.serialize
  end

  def update
    begin
      body=JSON.parse params[:body]
      @oauth_application.external_id=body['external_id'] if body.has_key?('external_id')
      @oauth_application.redirect_uri=body['redirect_uri'] if body.has_key?('redirect_uri')
      @oauth_application.enabled=body['enabled'] if body.has_key?('enabled')
      @oauth_application.name=body['name'] if body.has_key?('name')

      if body.has_key?('application_environment')
        ae=ApplicationEnvironment.find_or_create_by name: body['application_environment']
        @oauth_application.application_environment = ae
      end

      @oauth_application.save
      render json: @oauth_application.serialize, status: 200
    rescue => e
      render json: { error: e.message, backtrace: e.backtrace.inspect } , status: 500
    end
  end

  def create

    begin
      body=JSON.parse params[:body]
      @oauth_application = OauthApplication.create redirect_uri: body['redirect_uri'], name: body['name'], external_id: body['external_id']

      if body.has_key?('application_environment')
        ae=ApplicationEnvironment.find_by_name body['application_environment']
        @oauth_application.application_environment = ae
      end

      @oauth_application.save
      render json: @oauth_application.serialize

    rescue => e
      render json: { error: e.message, backtrace: e.backtrace.inspect } , status: 500
    end


  end

  def variable
    variable=Variable.find_by name: params[:variable_name]
    render json: { data: variable.data }
  end

  def save_variable
    variable=Variable.find_or_create_by name: params[:variable_name]
    variable.data=params[:payload][:data]
    variable.save
    render json: { message: 'variable saved', data: variable.data }
  end

  private
  def authorized
    begin
      key=ENV['SOFT_ENCRYPTION_KEY']
      auth=request.headers['Authorization']
      seed=request.headers['Seed']
      time=request.headers['Time']
      calculated_auth=Digest::SHA1.hexdigest([key,seed,time].join(','))
      unless auth==calculated_auth and (Time.now.to_i - time.to_i)<600
        raise 'unauthorized'
      end
    rescue
      render json: {}, status: 403
    end
  end

  def set_application
    @oauth_application=OauthApplication.find_by_uid params[:uid]
    render json: {}, status: 404 unless @oauth_application
  end
end
