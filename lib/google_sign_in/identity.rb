require 'google-id-token'

module GoogleSignIn
  class Identity
    class ValidationError < StandardError; end

    def initialize(token)
      ensure_client_id_present
      set_extracted_payload(token)
    end

    def uid
      @payload["sub"]
    end

    def iss
      @payload["iss"]
    end

    def name
      @payload["name"]
    end

    def email_address
      @payload["email"]
    end

    def email_verified?
      @payload["email_verified"] == true
    end

    def avatar_url
      @payload["picture"]
    end

    def locale
      @payload["locale"]
    end

    def hosted_domain
      @payload["hd"]
    end

    def given_name
      @payload["given_name"]
    end

    def family_name
      @payload["family_name"]
    end

    def domain
      email_address.split('@').last
    end

    private

    def client_id
      GoogleSignIn::Validator.client_id
    end

    def ensure_client_id_present
      if client_id.blank?
        raise ArgumentError, "GoogleSignIn.client_id must be set to validate identity"
      end
    end

    def set_extracted_payload(token)
      @payload = validator.check(token, client_id)
    rescue GoogleIDToken::ValidationError => error
      raise ValidationError, error.message
    end

    def validator
      GoogleSignIn::Validator.validator
    end
  end
end
