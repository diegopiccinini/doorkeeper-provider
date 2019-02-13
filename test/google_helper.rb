ENV['RAILS_ENV'] ||= 'test'

GOOGLE_CLIENT_ID = ENV['GOOGLE_CLIENT_ID']
GOOGLE_CLIENT_SECRET = ENV['GOOGLE_CLIENT_SECRET']

require 'webmock/minitest'
require 'byebug'


if GOOGLE_X509_CERTIFICATE.not_after <= Time.now
  raise "Test certificate is expired."
end


