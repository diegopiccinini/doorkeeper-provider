require 'test_helper'
require 'google_helper'

class GoogleSignInTest < ActiveSupport::TestCase
  test "certificate expired?" do
    cert_json=File.join(Rails.root,'certs','google.json')
    cert_pem=JSON.parse(File.read cert_json).values.first
    cert = OpenSSL::X509::Certificate.new cert_pem
    byebug

  end
end
