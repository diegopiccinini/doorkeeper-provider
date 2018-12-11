require 'test_helper'

class OauthApplicationsSiteTest < ActiveSupport::TestCase
  attr_reader :site1, :app1

  setup do
    @app1=oauth_applications(:one)
    @site1=sites(:one)
  end

  test "#site_url_contains" do
    assert OauthApplicationsSite.site_url_contains('test').count, 0

    app1.sites << site1

    assert OauthApplicationsSite.site_url_contains('test').count, 1
    assert OauthApplicationsSite.site_url_contains('test1').count, 1
    assert OauthApplicationsSite.site_url_contains('test2').count, 0
  end

  test "#oauth_application_name_contains" do
    assert OauthApplicationsSite.oauth_application_name_contains('test').count, 0

    app1.sites << site1

    assert OauthApplicationsSite.oauth_application_name_contains('test').count, 1
    assert OauthApplicationsSite.oauth_application_name_contains('prod').count, 1
    assert OauthApplicationsSite.oauth_application_name_contains('dev').count, 0
  end
end
