
module GoogleSignIn
  class Validator

    class << self
      def validator
        GoogleIDToken::Validator.new(x509_cert: GOOGLE_X509_CERTIFICATE)
      end

      def client_id
        ENV['GOOGLE_CLIENT_ID']
      end

      def secret
        ENV['GOOGLE_CLIENT_SECRET']
      end

      def key
        GOOGLE_PRIVATE_KEY
      end

      def iss
        'https://accounts.google.com'
      end

      def aud
        client_id
      end

      def exp
        Time.now + 10
      end
    end

  end
end
