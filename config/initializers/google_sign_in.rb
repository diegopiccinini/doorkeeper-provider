require 'openssl'
require 'json'

unless Rails.env=='production'
  cert_pem=File.expand_path File.join(Rails.root,'test','certificate.pem')
  key_pem=File.expand_path File.join(Rails.root,'test','key.pem')
  GOOGLE_X509_CERTIFICATE = OpenSSL::X509::Certificate.new File.read(cert_pem)
  GOOGLE_PRIVATE_KEY = OpenSSL::PKey::RSA.new File.read(key_pem)
else
  cert_json=File.join(Rails.root,'certs','google.json')
  cert_pem=JSON.parse(File.read cert_json).values.first
  GOOGLE_X509_CERTIFICATE = OpenSSL::X509::Certificate.new cert_pem
end
