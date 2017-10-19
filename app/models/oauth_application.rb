class OauthApplication < Doorkeeper::Application
  has_and_belongs_to_many :users
  has_and_belongs_to_many :sites

  scope :name_contains, -> (name) { where("name LIKE ? OR redirect_uri LIKE ?","%#{name}%","%#{name.downcase}%") }
  scope :name_ends, -> (name) { where("name LIKE ? ","%#{name}") }
  scope :name_ends_or, -> (name1,name2) { where("name LIKE ? OR name LIKE ? ","%#{name1}","%#{name2}") }
  scope :enabled, -> { where(enabled: true) }

  def tidy_sites
    sites.where( 'oauth_applications_sites.status': 'correct' ).order(:url).each.map { |s| s.url + '/callback' }.join(' ')
  end

  def update_sites
    update( redirect_uri: tidy_sites ) if tidy_sites!=''
  end

  def ip
    ips=sites.select('ip').group('ip').count('sites.id')
    max_value=ips.values.max
    ips.rassoc(max_value)[0]
  end

end
