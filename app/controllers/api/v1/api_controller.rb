module Api::V1
  class ApiController < ::ApplicationController
    def current_resource_owner
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
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
