require 'test_helper'

class UserSitesAccessTest < ActiveSupport::TestCase

  attr_accessor :user, :app_two, :app_granted, :superuser, :site_one, :site_two
  setup do
    @site_one= sites(:one)
    site_one.save
    @site_two= sites(:two)
    site_two.save
    @app_granted= oauth_applications(:one)
    app_granted.sites<< site_one
    app_granted.save
    app_site=OauthApplicationsSite.find_by site: site_one, oauth_application: app_granted
    app_site.update(status: OauthApplicationsSite::STATUS_ENABLED )

    @app_two=oauth_applications(:two)
    app_two.sites<< site_two
    app_two.save
    as2=OauthApplicationsSite.find_by site: site_two, oauth_application: app_two
    as2.update(status: OauthApplicationsSite::STATUS_ENABLED )
    @superuser=users(:superuser)
    superuser.save
    @user=users(:one)
    user.sites<< site_one
    user.save
    ApplicationEnvironment.update_application_stage_type_tags
    @everybody=oauth_applications :everybody
    @everybody_site= sites :everybody
  end

  test "by default has not access to site" do
    assert !user.has_access_to_site?( application: app_two , redirect_uri: site_one.url )
    assert !user.has_access_to_site?( application: nil, redirect_uri: site_one.url )
    assert !user.has_access_to_site?( application: nil, redirect_uri: site_two.url )
    assert !user.has_access_to_site?( application: app_granted, redirect_uri: nil)
    assert !user.has_access_to_site?( application: app_granted, redirect_uri: site_two.url )
    assert user.has_access_to_site?( application: @everybody, redirect_uri: @everybody_site.url )
  end

  test "granted to one application" do
    assert user.own_sites.count>0
    assert user.has_access_to_site?( application: app_granted, redirect_uri: site_one.url )
  end

  test "not access when the user is disabled" do
    user.update disabled: true
    assert !user.has_access_to_site?( application: app_granted, redirect_uri: site_one.url )
    user.update disabled: false
  end

  test "not access when the user is expired" do
    user.update expire_at: (DateTime.now - 1)
    assert !user.has_access_to_site?( application: app_granted, redirect_uri: site_one.url )
    user.update expire_at: (DateTime.now + 180)
  end

  test "has access is super login" do

    assert superuser.own_sites.count>0
    assert superuser.enabled_sites.count>0
    assert superuser.has_access_to_site?( application: app_granted, redirect_uri: site_one.url )
    assert superuser.has_access_to_site?( application: app_two, redirect_uri: site_two.url )
    assert !superuser.has_access_to_site?( application: app_granted, redirect_uri: site_two.url )
    assert !superuser.has_access_to_site?( application: app_two, redirect_uri: site_one.url )
  end

  test "superuser disabled has not access" do
    superuser.update disabled: true
    assert !superuser.has_access_to_site?( application: app_granted, redirect_uri: site_two.url )
    superuser.update disabled: false
  end

  test "superuser expired  has not access" do
    superuser.update expire_at: ( DateTime.now - 1 )
    assert !superuser.has_access_to_site?( application: app_granted, redirect_uri: site_one.url )
    assert superuser.own_sites.count==0
    assert superuser.enabled_sites.count==0
    superuser.update expire_at: ( DateTime.now + 180 )
  end

  test "has not access to disabled application" do
    app_granted.update enabled: false
    assert !user.has_access_to_site?( application: app_granted, redirect_uri: site_one.url )
    assert !superuser.has_access_to_site?( application: app_granted, redirect_uri: site_one.url )
    app_granted.update enabled: true
  end

end
