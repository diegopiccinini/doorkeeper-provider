require 'test_helper'

class OauthApplicationTest < ActiveSupport::TestCase
  include FixtureFileHelpers

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

  test "tags" do
    ApplicationEnvironment.update_application_stage_type_tags
    ActsAsTaggableOn::Tag.create( name: 'Tag1')
    ActsAsTaggableOn::Tag.create( name: 'Tag2')
    ActsAsTaggableOn::Tag.create( name: 'Tag3')

    two= oauth_applications(:two)
    assert_equal two.tag_list,[]
    assert_equal two.full_tags,['Dev']
    assert_equal ActsAsTaggableOn::Tag.count, 5

    two.tag_list.add 'Tag1'
    two.save
    assert_equal two.tag_list,['Tag1']
    assert_equal (two.full_tags - ['Dev','Tag1']),[]
    assert_equal ActsAsTaggableOn::Tag.count, 5
    tags = ActsAsTaggableOn::Tag.where( name: ['Dev', 'Tag1'] ).all
    assert_equal OauthApplication.with_tags(tags).first.id, two.id

    tags = ActsAsTaggableOn::Tag.where( name: ['Dev', 'Tag1','Tag2'] ).all
    assert_equal 0, OauthApplication.with_tags(tags).count
    tags = ActsAsTaggableOn::Tag.where( name: ['Dev', 'Tag2'] ).all
    assert_equal 0, OauthApplication.with_tags(tags).count
    assert_equal 2, OauthApplication.with_tags(tags, has_all: false).count

    tags = ActsAsTaggableOn::Tag.where( name: 'no_exist' ).all
    assert_equal  OauthApplication.with_tags(tags).count, 0
  end

  test "#backend_uri" do
    app=oauth_applications(:two)
    b = app.backend_uri
    assert b.size < app.redirect_uri.split.size
    assert b.size > 0
    back_count=b.count { |x| x.include? ENV['BACKEND_CALLBACK_URI_PATH'] }
    front_count=b.count { |x| x.include? ENV['FRONTEND_CALLBACK_URI_PATH'] }
    assert back_count > 0
    assert_equal front_count, 0
  end

  test "#frontend_uri" do
    app=oauth_applications(:two)
    b = app.frontend_uri
    back_count=b.count { |x| x.include? ENV['BACKEND_CALLBACK_URI_PATH'] }
    front_count=b.count { |x| x.include? ENV['FRONTEND_CALLBACK_URI_PATH'] }
    assert b.size < app.redirect_uri.split.size
    assert b.size > 0
    assert front_count > 0
    assert_equal back_count, 0
  end

  test "#redirect_uri_keep_frontend" do
    app=oauth_applications(:two)
    original_frontend_uri=app.frontend_uri
    redirect_uri=%w(testclient2 testclient3 testclient4).map { |x| back_uri x }.join(' ')
    app.redirect_uri_keep_frontend(redirect_uri)
    app.save
    app.reload
    assert_equal app.frontend_uri, original_frontend_uri.sort

    redirect_uri=%w(testclient2 testclient3).map { |x| back_uri x }.join(' ')
    app.redirect_uri_keep_frontend(redirect_uri)
    app.save
    app.reload
    assert_equal app.frontend_uri, original_frontend_uri.sort

    redirect_uri=%w(testclient3 testclient4).map { |x| back_uri x }.join(' ')
    app.redirect_uri_keep_frontend(redirect_uri)
    app.save
    app.reload
    assert_not_equal app.frontend_uri, original_frontend_uri.sort
    assert_no_match /testclient2/, app.frontend_uri.join(' ')
    assert_match /testclient3/, app.frontend_uri.join(' ')
  end

end
