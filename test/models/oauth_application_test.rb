require 'test_helper'

class OauthApplicationTest < ActiveSupport::TestCase

  test "#check_sites_for_redirect_uri" do
    one= oauth_applications(:one)
    hosts=('a'..'g').to_a.map { |x| "https://site_#{x}.test/path/uri/to/callback" }
    one.check_sites_for_redirect_uri hosts.join(' ')
    assert_equal OauthApplicationsSite.where( oauth_application: one, status: 'to check').count, hosts.count
  end

  test "#create_sites" do
    two= oauth_applications(:two)
    two.create_sites
    assert two.sites.count, 3
  end
end
