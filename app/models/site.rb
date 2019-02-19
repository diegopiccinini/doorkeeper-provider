require 'faraday'

class Site < ActiveRecord::Base

  acts_as_taggable

  STEP_CENTRAL_AUTH_302 = 'central auth redirection'
  STEP_NO_CENTRAL_AUTH_302 = 'no central auth redirection'
  STEP_BAD_RESPONSE = 'bad response'
  STEP_SITE_UNAVAILABLE = 'site unavailable'
  STEP_BLACK_LIST = 'black list'

  has_one :black_list

  has_and_belongs_to_many :oauth_applications
  has_many :oauth_applications_sites
  has_and_belongs_to_many :users

  before_save :update_total_oauth_applications

  scope :central_auth_redirection,-> { where( step: STEP_CENTRAL_AUTH_302 ) }

  scope :backend,-> { where( 'url LIKE ?',"%#{ENV['BACKEND_CALLBACK_URI_PATH']}" ) }

  scope :url_contains, -> (name) { where("url LIKE ? ","http%://%#{name.downcase}%/%") }

  scope :with_app,-> { joins(:oauth_applications_sites) }

  scope :enabled_joins,-> { includes(oauth_applications_sites: {oauth_application: :application_environment}).where('oauth_applications_sites.status': OauthApplicationsSite::STATUS_ENABLED) }

  def update_total_oauth_applications
    self.total_oauth_applications= oauth_application_ids.count
  end

  def to_s
    url
  end

  def uri
    URI(url)
  end

  def host
    uri.host
  end

  def host_url
    uri.scheme + '://' + uri.host
  end

  def apps
    oauth_applications.each.map { |x| x.name }.join(' | ')
  end

  def conn
    Faraday.new( url: host_url )
  end

  def first_call_backend_path
    uri.path.chomp('/callback')
  end

  def check

    self.step=STEP_BAD_RESPONSE
    begin
      response=conn.get do |req|
        req.url first_call_backend_path
        req.options.timeout=5
        req.options.open_timeout=2
      end

      if response.status==302
        self.step=STEP_NO_CENTRAL_AUTH_302
        if response.headers['location'].start_with?("https://#{ENV['HOST']}")
          self.step=STEP_CENTRAL_AUTH_302
          clean_duplication response.headers['location']
        end
      end
      self.status=response.status
    rescue
      self.status=443
      self.step=STEP_SITE_UNAVAILABLE
    end

    self.save
  end

  def delete_in_apps

    oauth_applications.each do |a|
      a.delete_redirect_uri self
    end

  end

  def enabled
    oauth_applications.where(enabled: true).count>0 &&
      oauth_applications_sites.where(status: OauthApplicationsSite::STATUS_ENABLED).count>0
  end

  def clean_duplication location

    if oauth_applications.count>1
      client_id=location["https://#{ENV['HOST']}/oauth/authorize/client_id=".size .. (location.index("&redirect_uri=") - 1)]
      oauth_applications.each do |a|
        if a.uid==client_id
          a.update( enabled: true)
          a.site_status(self, OauthApplicationsSite::STATUS_DUPLICATED_CORRECT)
          puts "\t--> The correct one is #{a.external_id}"
        else
          a.site_status(self, OauthApplicationsSite::STATUS_DUPLICATED_INCORRECT)
          puts "\t--> #{a.external_id} is wrong!"
        end
          puts
      end
    end
  end

  def set_ip
    update(ip: get_ip)
  end

  def get_ip
    begin
      IPSocket.getaddress(self.host)
    rescue SocketError
      false
    end
  end

  def self.any_tag_ids tags
    ae_ids=ApplicationEnvironment.tagged_with( tags, any: true).ids
    result=tagged_with( tags, any: true)
    app_ids=OauthApplication.where( application_environment_id: ae_ids ).ids
    total_ids=OauthApplicationsSite.where(oauth_application_id: app_ids).map { |app_site| app_site.site_id } + result.ids
    total_ids.uniq
  end

  def default_tag
    app=oauth_applications.first
    app.nil? ? 'Unknown' : app.application_environment.name
  end

  def full_tags
    tag_list + [ default_tag ]
  end

  def owner_apps
    oauth_applications.map { |a| a.external_id }.join(" | ")
  end

  def available_tags
    custom_tags.reject { |t| tag_list.include?t[:name] }
  end

  def custom_tags
    tags=ActsAsTaggableOn::Tag.all.reject { |t| OauthApplication.default_tags.include?(t.name) }
    tags.map { |t| { id: t.id , name: t.name } }
  end

  def callback_name
    url.end_with?('/callback') ? backend_name : frontend_name
  end

  def backend_name
    name=host
    name.include?('.') ? name.split('.').first : name
  end

  def frontend_name
    frontend_uri_params=Base64.strict_decode64(encoded_frontend).split
    frontend_uri_params.join(' ') + ' [FE]'
  end

  def encoded_frontend
    url.split('/').last
  end

  def applications
    oauth_applications.map { |a| a.external_id }.join(" | ")
  end

  def has_user? user
    users.where(id: user.id).count>0
  end

  def application
    oauth_applications.enabled.first
  end

  def login_url
    application.sync_excluded? ? url : callback_name
  end

  def app_uri
    extra_param=''
    extra_param="/#{encoded_frontend}" unless url.end_with?('/callback')
    url[0..(url.index('/callback') - 1 )] + extra_param
  end

end
