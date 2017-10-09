class OauthApplication < Doorkeeper::Application
  has_and_belongs_to_many :users
  scope :name_contains, -> (name) { where("name LIKE ? OR redirect_uri LIKE ?","%#{name.downcase}%","%#{name.upcase}%") }
  scope :name_ends, -> (name) { where("name LIKE ? ","%#{name.downcase}") }
end
