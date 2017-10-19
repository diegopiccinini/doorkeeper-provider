class Api::V1::OauthApplicationsController < ApplicationController
  before_action :authorized
  respond_to :json

  def index

    sites= OauthApplication.enabled.map do |a|
      a.redirect_uri.split.map { |site| [ site, a.name ] }
    end

    sites.flatten!(1)
    response_data = { type: :sites_enabled_list , count: sites.count, sites:  sites }

    render json: response_data

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
end
