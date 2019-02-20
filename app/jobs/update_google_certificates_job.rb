class UpdateGoogleCertificatesJob
  include SuckerPunch::Job

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      update_certificates
      GoogleCertificate.expired.delete_all
    end
  end

  def update_certificates
    get_certificates.each_pair do |key,body|
      cert=GoogleCertificate.find_or_create_by key: key
      update_cert_body cert, body if cert.start_on.nil?
    end
  end

  def get_certificates
    response=Faraday.get 'https://www.googleapis.com/oauth2/v1/certs'
    JSON.parse response.body
  end

  def update_cert_body google_cert, body
    google_cert.update_cert body
  end
end
