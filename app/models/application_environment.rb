class ApplicationEnvironment < ActiveRecord::Base
  has_many :oauth_applications
end
