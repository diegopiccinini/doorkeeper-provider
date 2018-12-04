require 'test_helper'

class ApplicationEnvironmentTest < ActiveSupport::TestCase

  attr_reader :app1, :app2, :site1, :site2

  test "update application stage type tags" do
    ApplicationEnvironment.update_application_stage_type_tags

    assert ActsAsTaggableOn::Tag.count>0
    end

  setup do
    @app1=oauth_applications(:one)
    @app2=oauth_applications(:two)
    @site1=sites(:one)
    @site2=sites(:two)
  end

  test "#by_sites" do
    assert ApplicationEnvironment.by_sites(Site.all).count, 0
  end

  test "one site with application" do
    app1.sites << site1
    assert ApplicationEnvironment.by_sites(Site.all).count, 1
    assert ApplicationEnvironment.by_sites(Site.all).map { |a| a.name }, ['dev']
  end

  test "two enviroments result" do
    app1.sites << site1
    app2.sites << site2
    assert ApplicationEnvironment.by_sites(Site.all).count, 2
    assert ApplicationEnvironment.by_sites(Site.all).map { |a| a.name }, ['dev','prod']
  end

end
