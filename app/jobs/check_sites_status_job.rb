class CheckSitesStatusJob
  include SuckerPunch::Job

  def perform oauth_application_id
    ActiveRecord::Base.connection_pool.with_connection do
      app=OauthApplication.find(oauth_application_id)
      check_sites app
    end
  end

  def check_response app
    app.sites.each do  |site|
      site.check
      oauth_app_site=OauthApplicationsSite.find_by site: site, oauth_application: app
      oauth_app_site.update(status: OauthApplicationsSite::STATUS_TO_CHECK)
    end
  end

  def check_status
    OauthApplicationsSite.to_check.each do |os|
      os.check
    end
  end

end
