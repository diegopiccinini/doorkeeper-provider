class OauthApplicationsUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :oauth_application
end
