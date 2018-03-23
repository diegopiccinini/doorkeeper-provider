require 'test_helper'

class UserTest < ActiveSupport::TestCase

  attr_accessor :user, :application, :app_granted, :superuser
  setup do
    @user=users(:one)
    @application=oauth_applications(:two)
    @application.save
    @app_granted=oauth_applications(:one)
    @app_granted.save
    @user.save
    @superuser=users(:superuser)
    @superuser.save
  end

  test "set a 180 days expiration before create" do
    assert user.expire_at.between?(DateTime.now + 179,DateTime.now + 181)
  end

  test "by default has not access to application" do
    assert !user.has_access_to?(application)
    assert !user.has_access_to?(nil)
  end

  test "granted to one application" do
    assert user.has_access_to?(app_granted)
  end

  test "not access when the user is disabled" do
    user.update disabled: true
    assert !user.has_access_to?(app_granted)
    user.update disabled: false
  end

  test "not access when the user is expired" do
    user.update expire_at: (DateTime.now - 1)
    assert !user.has_access_to?(app_granted)
    user.update expire_at: (DateTime.now + 180)
  end

  test "has access is super login" do
    assert superuser.has_access_to?(app_granted)
    assert superuser.has_access_to?(application)
  end

  test "superuser disabled has not access" do
    superuser.update disabled: true
    assert !superuser.has_access_to?(app_granted)
    superuser.update disabled: false
  end

  test "superuser expired  has not access" do
    superuser.update expire_at: ( DateTime.now - 1 )
    assert !superuser.has_access_to?(app_granted)
    superuser.update expire_at: ( DateTime.now + 180 )
  end

  test "has not access to disabled application" do
    app_granted.update enabled: false
    assert !user.has_access_to?(app_granted)
    assert !superuser.has_access_to?(app_granted)
    app_granted.update enabled: true
  end

  test "tag user" do
    ApplicationEnvironment.update_application_stage_type_tags
    user.tag_list.add 'Dev'
    user.save
    assert user.has_access_to?(application)
    assert_equal 1, User.with_access_to(application).where(id: user.id).count
    assert_equal 1, user.full_access.where(id: application.id).count

    user.tag_list.remove 'Dev'
    user.save
    assert !user.has_access_to?(application)
    assert_equal 0, User.with_access_to(application).where(id: user.id).count
    assert_equal 0, user.full_access.where(id: application.id).count

    application.tag_list.add 'testtag'
    application.save
    assert !user.has_access_to?(application)
    assert_equal 0, User.with_access_to(application).where(id: user.id).count
    assert_equal 0, user.full_access.where(id: application.id).count

    user.tag_list.add ['testtag','Dev']
    user.save
    assert user.has_access_to?(application)
    assert_equal 1, User.with_access_to(application).where(id: user.id).count
    assert_equal 1, user.full_access.where(id: application.id).count

    user.tag_list.add 'testtag2'
    user.save
    assert user.has_access_to?(application)
    assert_equal 1, User.with_access_to(application).where(id: user.id).count
    assert_equal 1, user.full_access.where(id: application.id).count

    user.tag_list.remove user.tag_list
    application.tag_list.remove 'testtag'
    user.save
    application.save
  end
end
