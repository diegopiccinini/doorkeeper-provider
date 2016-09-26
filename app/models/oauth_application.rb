class OauthApplication < Doorkeeper::Application
  has_and_belongs_to_many :users
end
