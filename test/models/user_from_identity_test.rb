require 'test_helper'
require 'google_helper'

class UserFromIdentityTest < ActiveSupport::TestCase

  setup do
    @user=User.from_identity identity
  end

  test "user was created" do
    assert_equal @user.email, payload[:email]
  end

end
