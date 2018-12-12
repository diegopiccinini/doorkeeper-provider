class CheckSitesStatusJob
  include SuckerPunch::Job

  def perform oauth_application_id
    ActiveRecord::Base.connection_pool.with_connection do
      app=OauthApplication.find(oauth_application_id)
      app.sites.each do  |site|
        site.check
      end
    end
  end

end
