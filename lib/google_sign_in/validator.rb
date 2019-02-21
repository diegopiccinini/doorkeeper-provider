
module GoogleSignIn
  class Validator

    class << self
      def validator cert:
        GoogleIDToken::Validator.new(x509_cert: cert )
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
        Time.now + 1000
      end

      def user_payload user
        {
          exp: 2.hours.from_now.to_i,
          iss: iss,
          aud: aud,
          cid: client_id,
          sub: user.uid,
          email: user.email,
          verified: true,
          given_name: user.first_name,
          family_name: user.last_name,
          name: user.name
        }
      end

      def user_token user
        JWT.encode(user_payload(user), key, 'RS256')
      end

    end

  end
end
