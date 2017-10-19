class OauthApplicationsSite < ActiveRecord::Base
  belongs_to :site
  belongs_to :oauth_application
end
