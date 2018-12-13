require 'test_helper'

class CheckSitesStatusJobTest < ActiveSupport::TestCase
  attr_accessor :job, :app, :site, :association

  setup do
    @job=CheckSitesStatusJob.new
    @app=oauth_applications(:one)
    @site=sites(:one)
    stub_request(:get, "https://test1.bookingbug.com/logins/auth/bookingbug").
      with(  headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent'=>'Faraday v0.12.2'
    }).
    to_return(status: 302, body: "", headers: {})

    app.sites << site
    @association=OauthApplicationsSite.find_by site: site, oauth_application: app
    assert_nil association.status
    assert site.status , 1
  end

  test "#check_response" do
    job.check_response app
    site.reload
    assert site.status , 302
    association.reload
    assert association.status, OauthApplicationsSite::STATUS_TO_CHECK
  end

  test "#check_status STEP_CENTRAL_AUTH_302" do
    site.update( step: Site::STEP_CENTRAL_AUTH_302, status: 302)
    association.update( status: OauthApplicationsSite::STATUS_TO_CHECK)
    job.check_status
    assert association.status, OauthApplicationsSite::STATUS_ENABLED
  end

  test "#check_status STEP_BAD_RESPONSE" do
    site.update( step: Site::STEP_BAD_RESPONSE, status: 500)
    association.update( status: OauthApplicationsSite::STATUS_TO_CHECK)
    job.check_status
    assert association.status, OauthApplicationsSite::STATUS_BLACK_LIST
  end
end
