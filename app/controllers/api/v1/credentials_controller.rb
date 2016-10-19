module Api::V1
  require 'openssl'
  require 'encryptor'
  class CredentialsController < ApiController
    before_action :doorkeeper_authorize!, only: :me
    skip_before_action :verify_authenticity_token, only: :keys

    respond_to :json

    def me
      respond_with current_resource_owner
    end

    def keys
      # secret to encrypt and decrypt data
      @secret = Base64.decode64 ENV['ENCRYPTOR_KEY']

      if check_signature
        data= JSON.parse decrypt
        application=OauthApplication.where("redirect_uri LIKE :query", query: "%#{data['hostname']}%").first

        unless application
          application = OauthApplication.new
          application.redirect_uri = data['redirect_uri']
          application.name = data['name']
          application.save
        end
        data, iv, salt = encrypt application.to_json
        response_data = { data: data, iv: iv, salt: salt }
        response_data[:signature] = sign response_data
      else
        # return empty json when the request signature is wrong
        response_data = {}
      end
      render json: response_data
    end

    private
    def decrypt
      iv = Base64.decode64 params[:iv]
      salt = Base64.decode64 params[:salt]
      data = Base64.decode64 params[:data]
      Encryptor.decrypt(value: data, key: @secret, iv: iv, salt: salt)
    end
    def encrypt data
      cipher = OpenSSL::Cipher.new('aes-256-gcm')
      cipher.encrypt
      salt=SecureRandom.random_bytes(16)
      iv = cipher.random_iv # Insures that the IV is the correct length respective to the algorithm used.
      encrypted_data = Encryptor.encrypt(value: data, key: @secret, iv: iv, salt: salt)
      [encrypted_data, iv, salt].map { |x| Base64.encode64 x }
    end

    def check_signature
      validation = (['data','salt','iv','signature'] - params.to_hash.keys).empty? # check params
      validation = validation && sign(params) == params[:signature] # check signature
      validation
    end
    def sign params_hash
      s = OpenSSL::HMAC.hexdigest('sha256',@secret,params_hash[:data])
      s = OpenSSL::HMAC.hexdigest('sha256',s,params_hash[:salt] )
      OpenSSL::HMAC.hexdigest('sha256',s,params_hash[:iv])
    end
  end
end
