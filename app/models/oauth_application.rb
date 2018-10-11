class OauthApplication < Doorkeeper::Application

  acts_as_taggable

  has_and_belongs_to_many :users
  has_and_belongs_to_many :sites
  belongs_to :application_environment

  validates :external_id, presence: true, uniqueness: true

  scope :name_contains, -> (name) { where("name LIKE ? OR redirect_uri LIKE ?","%#{name.upcase}%","%#{name.downcase}%") }
  scope :name_ends, -> (name) { where("name LIKE ? ","%#{name.upcase}") }
  scope :name_ends_or, -> (name1,name2) { where("name LIKE ? OR name LIKE ? ","%#{name1.upcase}","%#{name2.downcase}") }
  scope :enabled, -> { where(enabled: true) }

  def tidy_sites
    sites.where( 'oauth_applications_sites.status': OauthApplicationsSite::STATUS_CORRECT ).order(:url).each.map { |s| s.url + '/callback' }.join(' ')
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
      s=Site.find_or_create_by url: callback_uri
      sites << s
      oapp_site=OauthApplicationsSite.find_by site: s , oauth_application: self
      oapp_site.update( status: OauthApplicationsSite::STATUS_TO_CHECK )
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

  def redirect_uri_keep_frontend data

    hosts=data.split.map { |x| URI(x).host }
    frontends=frontend_uri.select { |x| hosts.include?URI(x).host }
    new_redirect_uri = data.split + frontends
    self.redirect_uri=new_redirect_uri.sort.join(' ')

  end

  def backend_uri
    redirect_uri.split.each.select { |x| x.include?ENV['BACKEND_CALLBACK_URI_PATH'] }
  end

  def frontend_uri
    redirect_uri.split.each.select { |x| x.include?ENV['FRONTEND_CALLBACK_URI_PATH'] }
  end

  def backend_uri_host
    backend_uri.map { |x| URI(x).host }
  end

  def add_frontend backend_host: , frontend_url:, company_id: nil
    backend=backend_uri.select { |x| x.include? backend_host }.first

    unless backend.nil?
      frontend_url << " #{company_id}" unless company_id.nil?
      front_redirect_uri= create_front_uri backend, frontend_url

      unless redirect_uri.include?(front_redirect_uri)
        uris=redirect_uri.split
        uris << front_redirect_uri
        self.redirect_uri=uris.sort.join(' ')
        save
      end
    end

  end

  def create_front_uri backend, frontend_url
    url=URI.parse backend
    url.scheme  + '://' + url.host + ENV['FRONTEND_CALLBACK_URI_PATH'] + '/' + Base64.strict_encode64(frontend_url)
  end

  def delete_frontend frontend
    uris=redirect_uri.split
    uris.delete(frontend)
    self.redirect_uri=uris.join(' ')
    save
  end

  def create_sites

    redirect_uri.split.each do |callback_uri|
      s=Site.find_or_create_by url: callback_uri
      sites << s unless sites.include?s
      oapp_site=OauthApplicationsSite.find_by site: s , oauth_application: self
      oapp_site.update( status: OauthApplicationsSite::STATUS_TO_CHECK)
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
        enabled: enabled,
        sync_excluded: sync_excluded
      }
    }
  end

  def default_tag
    application_environment.name
  end

  def full_tags
    tag_list + [ default_tag ]
  end

  def available_tags
    custom_tags.reject { |t| tag_list.include?t[:name] }
  end

  def custom_tags
    tags=ActsAsTaggableOn::Tag.all.reject { |t| OauthApplication.default_tags.include?(t.name) }
    tags.map { |t| { id: t.id , name: t.name } }
  end

  def site_status site, status=nil
    oapp_site=OauthApplicationsSite.find_or_create_by site: site , oauth_application: self
    oapp_site.update( status: status) if status
    oapp_site.status
  end

  def self.default_tags
    ApplicationEnvironment.all.map { |ae| ae.name }
  end

  def self.with_tags tags, has_all: true

    tag_names=tags.map { |t| t.name }
    c_tags = tag_names - default_tags
    default_tag_names = tag_names - c_tags

    ae_ids=ApplicationEnvironment.tagged_with(default_tag_names, any: true).ids

    if has_all
      apps_ids=tagged_with_ids(c_tags, match_all: true)
      where(id: apps_ids).where(application_environment_id: ae_ids)
    else
      apps_ids=tagged_with_ids(c_tags, any: true)
      if ae_ids.empty?
        where(id: apps_ids)
      elsif apps_ids.empty?
        where(application_environment_id: ae_ids)
      else
        where(id: apps_ids).where(application_environment_id: ae_ids)
      end
    end

  end

  def self.any_tag_ids tags
    ae_ids=ApplicationEnvironment.tagged_with( tags, any: true).ids
    result=ActsAsTaggableOn::Tagging.where(taggable_type: 'Doorkeeper::Application').where(tag_id: tags.ids).group(:taggable_id).count(:tag_id)
    total_ids=where( application_environment_id: ae_ids ).ids + result.keys
    total_ids.uniq
  end

  def self.tagged_with_ids names, match_all: false, any: false
    tag_ids=ActsAsTaggableOn::Tag.where(name: names).ids
    app_ids=[]
    result=ActsAsTaggableOn::Tagging.where(taggable_type: 'Doorkeeper::Application').where(tag_id: tag_ids).group(:taggable_id).count(:tag_id)
    if match_all
      app_ids=result.select { |k,v| v==tag_ids.size }.keys
    end
    app_ids=result.keys if any
    app_ids
  end

  def self.including_tags tags
    d_tags=tags.where(name: default_tags)
    if d_tags.empty?
      where( id: -10000 )
    else
      ae_ids=ApplicationEnvironment.tagged_with(d_tags, any: true).ids
      tag_ids=tags.ids - d_tags.ids
      # only exclude when the app has tags not included
      result=ActsAsTaggableOn::Tagging.where(taggable_type: 'Doorkeeper::Application').where.not(tag_id: tag_ids).group(:taggable_id).count(:tag_id)
      where( application_environment_id: ae_ids ).where.not( id: result.keys)
    end
  end
end
