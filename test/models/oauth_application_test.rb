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
    assert_equal 1, OauthApplication.with_tags(tags, has_all: false).count

    tags = ActsAsTaggableOn::Tag.where( name: 'no_exist' ).all
    assert_equal  OauthApplication.with_tags(tags).count, 0
  end

end
