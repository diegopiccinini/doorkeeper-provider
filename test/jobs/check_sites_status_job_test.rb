require 'test_helper'

class CheckSitesStatusJobTest < ActiveSupport::TestCase
  attr_accessor :job, :app, :site

  setup do
    @app=oauth_applications(:one)
    @site=sites(:one)
    stub_request(:get, "https://test1.bookingbug.com/logins/auth/bookingbug").
      with(  headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent'=>'Faraday v0.12.2'
    }).
    to_return(status: 302, body: "", headers: {})

  end

  test "new sites change status" do
    app.sites << site
    association=OauthApplicationsSite.find_by site: site, oauth_application: app
    assert_nil association.status
    assert site.status , 1
    @job=CheckSitesStatusJob.perform_async app.id
    site.reload
    assert site.status , 302
  end
end
