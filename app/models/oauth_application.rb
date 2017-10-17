class OauthApplication < Doorkeeper::Application
  has_and_belongs_to_many :users
  has_and_belongs_to_many :sites
  scope :name_contains, -> (name) { where("name LIKE ? OR redirect_uri LIKE ?","%#{name}%","%#{name.downcase}%") }
  scope :name_ends, -> (name) { where("name LIKE ? ","%#{name}") }
  scope :name_ends_or, -> (name1,name2) { where("name LIKE ? OR name LIKE ? ","%#{name1}","%#{name2}") }
  scope :enabled, -> { where(enabled: true) }
end
