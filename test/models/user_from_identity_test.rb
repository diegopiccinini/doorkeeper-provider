require 'test_helper'
require 'google_helper'

class UserFromIdentityTest < ActiveSupport::TestCase

  setup do
    @user=User.from_identity identity
  end

  test "email match" do
    assert_match @user.email, payload[:email]
  end

  test "provider match" do
    assert_equal @user.provider , payload[:iss]
  end

  test "uid match" do
    assert_equal @user.uid, payload[:sub]
  end

  test "name match" do
    assert_equal @user.name , payload[:name]
  end

  test "first name match" do
    assert_equal @user.first_name , payload[:given_name]
  end

  test "last name match" do
    assert_equal @user.last_name , payload[:family_name]
  end

end
