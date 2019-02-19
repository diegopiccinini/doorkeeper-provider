require 'test_helper'

class UpdateGoogleCertificatesJobTest < ActiveJob::TestCase
  def stub_calls
    cert_json=File.join(Rails.root,'test','google.json')
    body= File.read cert_json
    stub_request(:get, "https://www.googleapis.com/oauth2/v1/certs").
      with(  headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent'=>'Faraday v0.12.2'
    }).
    to_return(status: 200, body: body, headers: {})
  end

  setup do
    stub_calls
    @job=UpdateGoogleCertificatesJob.new
  end

  test "has valid keys" do
    assert_equal @job.get_certificates.keys.count, 3
  end

  test "perform" do
    GoogleCertificate.delete_all
    @job.perform
    assert_equal GoogleCertificate.count , 3
    GoogleCertificate.all.each do |gc|
      assert_not_nil gc.key
      assert_not_nil gc.body
      assert_not_nil gc.start_on
      assert_not_nil gc.expire_at
      assert_operator gc.expire_at, :>, gc.start_on
    end
  end
end
