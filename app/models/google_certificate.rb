require 'openssl'

class GoogleCertificate < ActiveRecord::Base

  scope :in_effect,-> { where("start_on <= ? and expire_at > ?", Time.now, Time.now).order(id: :desc) }

  scope :expired,-> { where("expire_at < ?", Time.now) }

  def cert
    @cert||= OpenSSL::X509::Certificate.new body
  end

  def update_cert new_body
    update( body: new_body)
    update( start_on: cert.not_before, expire_at: cert.not_after )
  end

  def self.create_test_certificate
    require 'digest'
    cert_pem=File.read File.expand_path(File.join(Rails.root,'test','certificate.pem'))
    key= Digest::MD5.hexdigest cert_pem
    obj=find_or_create_by key: key
    obj.update_cert cert_pem
  end
end
