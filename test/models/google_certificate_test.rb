require 'test_helper'

class GoogleCertificateTest < ActiveSupport::TestCase
  setup do
    GoogleCertificate.delete_all
  end

  teardown do
    GoogleCertificate.create_test_certificate
  end

  test "in_effect" do
    GoogleCertificate.create key: SecureRandom.hex, body: SecureRandom.hex(30) , start_on: 1.day.ago, expire_at: 1.day.from_now
    assert_equal GoogleCertificate.in_effect.count, 1
  end

  test "expired" do
    GoogleCertificate.create key: SecureRandom.hex, body: SecureRandom.hex(30) , start_on: 1.day.ago, expire_at: 1.day.from_now
    GoogleCertificate.create key: SecureRandom.hex, body: SecureRandom.hex(30) , start_on: 3.day.ago, expire_at: 1.day.ago
    assert_equal GoogleCertificate.expired.count, 1
    assert_equal GoogleCertificate.in_effect.count, 1
    GoogleCertificate.expired.delete_all
    assert_equal GoogleCertificate.in_effect.count, 1
    assert_equal GoogleCertificate.expired.count, 0
  end
end
