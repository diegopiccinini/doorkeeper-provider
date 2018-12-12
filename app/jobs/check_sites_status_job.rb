class CheckSitesStatusJob
  include SuckerPunch::Job

  def perform oauth_application_id
    raise NotImplementedError
  end

end
