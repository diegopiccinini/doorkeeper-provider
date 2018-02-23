class OauthApplication < Doorkeeper::Application
  has_and_belongs_to_many :users
  has_and_belongs_to_many :sites
  belongs_to :application_environment

  validates :external_id, presence: true, uniqueness: true

  scope :name_contains, -> (name) { where("name LIKE ? OR redirect_uri LIKE ?","%#{name.upcase}%","%#{name.downcase}%") }
  scope :name_ends, -> (name) { where("name LIKE ? ","%#{name.upcase}") }
  scope :name_ends_or, -> (name1,name2) { where("name LIKE ? OR name LIKE ? ","%#{name1.upcase}","%#{name2.downcase}") }
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

  def check_sites_for_redirect_uri data

    OauthApplicationsSite.where( oauth_application: self).delete_all

    data.split.each do |callback_uri|
      next if callback_uri.size< ('/callback'.size + 8)
      s=Site.find_or_create_by url: callback_uri[0..-( '/callback'.size + 1)]
      sites << s
      oapp_site=OauthApplicationsSite.find_by site: s , oauth_application: self
      oapp_site.update( status: 'to check')
    end

  end

  def delete_redirect_uri site

    redirect_uris=redirect_uri.split.reject { |x| x.include?(site.url) }

    if redirect_uris.count<1
      update( enabled: false )
      puts "\t--> Bad url #{site.url} disabled application #{external_id}"
    else
      update( redirect_uri: redirect_uris.join(' ') )
      puts "\t--> #{site.url} deleted in #{external_id}"
    end

  end

  def create_sites

    redirect_uri.split.each do |callback_uri|
      next if callback_uri.size< ('/callback'.size + 8)
      s=Site.find_or_create_by url: callback_uri[0..-( '/callback'.size + 1)]
      sites << s
      oapp_site=OauthApplicationsSite.find_by site: s , oauth_application: self
      oapp_site.update( status: 'to check')
    end

  end

  def serialize
    { type: :oauth_application,
      attributes: {
      name: name,
      uid: uid,
      redirect_uri: redirect_uri,
      external_id: external_id,
      application_environment: application_environment.name,
      enabled: enabled
      }
    }
  end

end
