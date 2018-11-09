require 'test_helper'

require_relative './user_sites_access_test.rb'

class UserSitesTagAccessTest < UserSitesAccessTest

  test "default tag" do
    site_one.tag_list.add 'TestCustomTag1'
    user.tag_list.add 'Dev'
    user.save
    assert user.has_access_to_site?( application: app_two, redirect_uri: site_two.url )
    assert_equal 1, User.with_access_to_site(site_two).where(id: user.id).count
    assert_equal 1, user.full_site_access.where(id: site_two.id).count

    user.tag_list.remove 'Dev'
    user.save
    user.reload
  end

  test "without tags" do

    assert !user.has_access_to_site?( application: app_two, redirect_uri: site_two.url)
    assert_equal 0, User.with_access_to_site(site_two).where(id: user.id).count
    assert_equal 0, user.full_site_access.where(id: site_two.id).count

  end

  test "adding a tag to a site should not be enoght to give access to the user" do

    site_two.tag_list.add 'testtag'
    site_two.save

    assert !user.has_access_to_site?( application: app_two, redirect_uri: site_two.url)
    assert_equal 0, User.with_access_to_site(site_two).where(id: user.id).count
    assert_equal 0, user.full_site_access.where(id: site_two.id).count

    site_two.tag_list.remove 'testtag'
    site_two.save

  end

  test "adding the same tag to user and site should give access to the user" do

    site_two.tag_list.add 'testtag'
    site_two.save

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
    user.save
    site_two.tag_list.remove site_two.tag_list
    site_two.save
  end
end
