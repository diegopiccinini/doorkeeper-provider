require 'test_helper'

class CheckSitesStatusJobTest < ActiveSupport::TestCase
  attr_accessor :job, :app, :site

  setup do
    @app=oauth_applications(:one)
    @site=sites(:one)
    @job=CheckSitesStatusJob.perform_async app.id
  end

  test "new sites change status" do
    app.sites << site
    association=OauthApplicationsSite.find_by site: site, oauth_application: app
    assert association.status,'new site'
  end
end
