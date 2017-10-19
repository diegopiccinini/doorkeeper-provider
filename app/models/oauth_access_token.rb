class OauthAccessToken < Doorkeeper::AccessToken
  belongs_to :user, foreign_key: "resource_owner_id"
end
