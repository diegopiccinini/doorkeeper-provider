require 'test_helper'

class UserSitesAccessTest < ActiveSupport::TestCase

  attr_accessor :user, :app_two, :app_granted, :superuser, :site_one, :site_two
  setup do
    @site_one= sites(:one)
    site_one.save
    @site_two= sites(:two)
    site_two.save
    @app_granted= oauth_applications(:one)
    app_granted.sites<< sites(:one)
    app_granted.save
    @app_two=oauth_applications(:two)
    app_two.sites<< sites(:two)
    app_two.save
    @superuser=users(:superuser)
    superuser.save
    @user=users(:one)
    user.sites<< site_one
    user.save
  end

  test "by default has not access to site" do
    assert !user.has_access_to_site?( application: app_two , redirect_uri: site_one.url )
    assert !user.has_access_to_site?( application: nil, redirect_uri: site_one.url )
    assert !user.has_access_to_site?( application: nil, redirect_uri: site_two.url )
    assert !user.has_access_to_site?( application: app_granted, redirect_uri: nil)
    assert !user.has_access_to_site?( application: app_granted, redirect_uri: site_two.url )
  end

  test "granted to one application" do
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
    superuser.update expire_at: ( DateTime.now + 180 )
  end

  test "has not access to disabled application" do
    app_granted.update enabled: false
    assert !user.has_access_to_site?( application: app_granted, redirect_uri: site_one.url )
    assert !superuser.has_access_to_site?( application: app_granted, redirect_uri: site_one.url )
    app_granted.update enabled: true
  end

  test "tag user" do
    ApplicationEnvironment.update_application_stage_type_tags
    site_one.tag_list.add 'TestCustomTag1'
    user.tag_list.add 'Dev'
    user.save
    assert user.has_access_to_site?( application: app_two, redirect_uri: site_two.url )
    assert_equal 1, User.with_access_to_site(site_two).where(id: user.id).count
    assert_equal 1, user.full_site_access.where(id: site_two.id).count

    user.tag_list.remove 'Dev'
    user.save
    user.reload

    assert !user.has_access_to_site?( application: app_two, redirect_uri: site_two.url)
    assert_equal 0, User.with_access_to_site(site_two).where(id: user.id).count
    assert_equal 0, user.full_site_access.where(id: site_two.id).count

    site_two.tag_list.add 'testtag'
    site_two.save
    assert !user.has_access_to_site?( application: app_two, redirect_uri: site_two.url)
    assert_equal 1, User.with_access_to_site(site_two).where(id: user.id).count
    assert_equal 1, user.full_site_access.where(id: site_two.id).count


    user.tag_list.add ['testtag']
    user.save
    assert user.has_access_to_site?( application: app_two, redirect_uri: site_two.url)
    assert_equal 1, User.with_access_to_site(site_two).where(id: user.id).count
    assert_equal 1, user.full_site_access.where(id: site_two.id).count

    user.tag_list.add 'testtag2'
    user.save
    assert user.has_access_to_site?( application: app_two, redirect_uri: site_two.url)
    assert_equal 1, User.with_access_to_site(site_two).where(id: user.id).count
    assert_equal 1, user.full_site_access.where(id: site_two.id).count

    user.tag_list.remove user.tag_list
    site_two.tag_list.remove 'testtag'
    user.save
    site_two.tag_list.remove 'TestCustomTag1'
    site_two.save
  end
end
