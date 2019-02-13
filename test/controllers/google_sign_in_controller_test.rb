require 'test_helper'
require 'google_helper'

class GoogleSignInControllerTest < ActionController::TestCase
   test "tokensignin" do
     post :tokensignin , token_id: 'x'
     assert_equal 'x', assigns(:token_id)
   end
end
