require 'test_helper'
require 'helpers/authentication_helper'

class Api::V1::OauthApplicationsControllerTest < ActionController::TestCase
  setup do
    signature_headers.each_pair do | k, v |
      @request.headers[k]=v
    end
    stub_request(:get, "https://testclient.bookingbug.com/logins/auth/bookingbug").
      with(  headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent'=>'Faraday v0.12.2'
    }).
    to_return(status: 302, body: "", headers: { location: "https://localhost" })

    stub_request(:get, "https://testclient3.test.com/login").
      with(  headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent'=>'Faraday v0.12.2'
    }).
    to_return(status: 302, body: "", headers: { location: "https://localhost" })
  end

  test "show" do
    oauth_app=oauth_applications :one
    get :show, { 'uid' => oauth_app.uid }
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
    put :update, { 'uid' => oauth_app.uid, 'body' => body.to_json }
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
    post :create, { 'body' => body.to_json }
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
