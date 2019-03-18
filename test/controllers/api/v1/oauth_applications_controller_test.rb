require 'test_helper'
require 'helpers/authentication_helper'

class Api::V1::OauthApplicationsControllerTest < ActionController::TestCase

  def stub_all_calls
    stub_get_request_302 "https://testclient.bookingbug.com/logins/auth/bookingbug"
    stub_get_request_302 "https://testclient3.test.com/login"
    stub_get_request "https://testclient.#{ENV['CUSTOM_DOMAIN_FILTER']}/backend/path"
  end

  def stub_get_request_302 url
    stub_request(:get, url ).with(  headers: stub_with_headers ).to_return(status: 302, body: "", headers: { location: "https://localhost" })
  end

  setup do
    stub_all_calls
    signature_headers.each_pair do | k, v |
      @request.headers[k]=v
    end
  end

  test "show" do
    oauth_app=oauth_applications :one
    get :show, params: { 'uid' => oauth_app.uid }
    assert_response :success

    data=JSON.parse @response.body
    attributes=data['attributes']
    assert_equal data['type'],'oauth_application'
    assert_equal oauth_app.uid,attributes['uid']
    assert_equal oauth_app.external_id,attributes['external_id']
    assert_equal oauth_app.sync_excluded,attributes['sync_excluded']
  end

  test "update" do
    oauth_app=oauth_applications :one
    body = { 'external_id' => 'testclient_dev', 'application_environment' => 'Dev' }
    put :update, params: { 'uid' => oauth_app.uid, 'body' => body.to_json }
    assert_response :success

    data=JSON.parse @response.body
    attributes=data['attributes']
    assert_equal data['type'],'oauth_application'
    assert_equal oauth_app.uid,attributes['uid']
    assert_equal body['external_id'],attributes['external_id']
    assert_equal body['application_environment'],attributes['application_environment']
  end

  test "create" do

    body = { 'redirect_uri' => 'https://testclient3.test.com/login/callback', 'external_id' => 'testclient3_web', 'application_environment' => 'Prod' }
    post :create, params: { 'body' => body.to_json }
    assert_response :success

    data=JSON.parse @response.body
    attributes=data['attributes']

    assert data['type'],'oauth_application'
    assert attributes.has_key?('uid')
    assert_equal body['external_id'],attributes['external_id']
    assert_equal body['application_environment'],attributes['application_environment']
    assert_equal body['redirect_uri'],attributes['redirect_uri']

  end

end
