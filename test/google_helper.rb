ENV['RAILS_ENV'] ||= 'test'

GOOGLE_CLIENT_ID = ENV['GOOGLE_CLIENT_ID']
GOOGLE_CLIENT_SECRET = ENV['GOOGLE_CLIENT_SECRET']

require 'webmock/minitest'
require 'byebug'

require 'openssl'
require 'json'

cert_json=File.join(Rails.root,'certs','google.json')
cert_pem=JSON.parse(File.read cert_json).values.first

GOOGLE_X509_CERTIFICATE = OpenSSL::X509::Certificate.new cert_pem

if GOOGLE_X509_CERTIFICATE.not_after <= Time.now
  raise "Test certificate is expired."
end


