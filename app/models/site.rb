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
  has_and_belongs_to_many :users

  before_save :update_total_oauth_applications

  scope :central_auth_redirection,-> { where( step: STEP_CENTRAL_AUTH_302 ) }

  scope :backend,-> { where( 'url LIKE ?',"%#{ENV['BACKEND_CALLBACK_URI_PATH']}" ) }

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
    ENV['FIRST_CALL_BACKEND_PATH'] || uri.path
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
    oauth_applications.where(enabled: true).count>0
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
    oauth_applications.first.application_environment.name
  end

  def full_tags
    tag_list + [ default_tag ]
  end
end
