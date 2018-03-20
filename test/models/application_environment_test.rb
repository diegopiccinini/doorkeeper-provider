require 'test_helper'

class ApplicationEnvironmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "update application stage type tags" do
    ApplicationEnvironment.update_application_stage_type_tags

    assert ActsAsTaggableOn::Tag.count>0
  end
end
