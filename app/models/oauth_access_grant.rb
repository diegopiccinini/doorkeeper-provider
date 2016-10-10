class OauthAccessGrant < Doorkeeper::AccessGrant
  belongs_to :user, foreign_key: "resource_owner_id"

  def user_name
    user.name
  end
end
