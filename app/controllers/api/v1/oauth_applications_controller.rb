class Api::V1::OauthApplicationsController < ApplicationController
  respond_to :json

  def index

    response_data = {}

    if authorized
      sites= OauthApplication.enabled.map do |a|
        a.redirect_uri.split.map { |site| [ site, a.name ] }
      end

      sites.flatten!(1)
      response_data = { type: :sites_enabled_list , count: sites.count, sites:  sites }

    end
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
      auth==calculated_auth and (Time.now.to_i - time.to_i)<600
    rescue
      false
    end
  end
end
