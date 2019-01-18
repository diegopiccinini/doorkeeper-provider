class User < ActiveRecord::Base

  acts_as_taggable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2]
  has_and_belongs_to_many :oauth_applications
  has_and_belongs_to_many :sites
  has_many :oauth_access_grants, foreign_key: "resource_owner_id", dependent: :delete_all
  has_many :oauth_access_tokens, foreign_key: "resource_owner_id", dependent: :delete_all

  before_save { self.expire_at = DateTime.now + 180 unless self.expire_at }

  scope :access_with_tag, -> (oauth_application) { tagged_with(oauth_application.full_tags, any: true).where(disabled: false) }
  scope :site_access_with_tag, -> (site) { tagged_with(site.full_tags, any: true) }
  scope :name_contains, -> (name) { where("name LIKE ? ","%#{name}%") }

  def self.with_access_to oauth_application
    uids= where( super_login: true, disabled: false ).ids
    uids+= access_with_tag(oauth_application).ids
    uids+= oauth_application.users.where(disabled: false).ids
    where( id: uids )
  end

  def self.with_access_to_site site

    if site.enabled
      uids= where( super_login: true, disabled: false ).ids
      uids+= site_access_with_tag( site ).ids
      uids+= site.users.where(disabled: false).ids
      where( id: uids )
    else
      where( id: -1 )
    end

  end

  def self.with_access_to_site_level site

    if site.enabled
      uids= where( super_login: true, disabled: false ).ids
      uids+= site_access_with_tag( site ).ids
      uids+= site.users.where(disabled: false).ids
      where( id: uids )
    else
      where( id: -1 )
    end

  end

  def self.site_access_by_application site

    uids=[]
    site.oauth_applications.each do |app|
      uids+= app.tagged_users.ids
      uids+= app.users.ids
    end

    where( id: uids )
  end

  def to_s
    email
  end

  def self.from_omniauth(auth)
    if ENV['CUSTOM_DOMAIN_FILTER'].split.include?(auth[:info][:email].split('@').last)
      user = find_or_create_by email: auth[:info][:email]

      user.provider = auth[:provider]
      user.uid = auth[:uid]
      user.name = auth[:info][:name]
      user.first_name = auth[:info][:first_name]
      user.last_name = auth[:info][:last_name]
      #     user.super_login = true unless user.persisted?
      user.save(validate: false)
      user
    end
  end

  def applications
    if self.disabled
      OauthApplication.where("false")
    elsif self.super_login
      OauthApplication
    else
      full_access
    end
  end

  def own_sites
    if self.disabled || self.expired?
      Site.where("false")
    elsif self.super_login
      Site
    else
      full_site_access
    end
  end

  def enabled_sites
    own_sites.joins(:oauth_applications_sites).where("oauth_applications_sites.status = ? ", OauthApplicationsSite::STATUS_ENABLED)
  end

  def enabled_applications
    applications.where( enabled: true )
  end

  def enabled_application_names
    enabled_applications.map { |a| a.name }.join(', ')
  end

  def disabled_applications
    applications.where( enabled: false )
  end

  def disabled_application_names
    disabled_applications.map { |a| a.name }.join(', ')
  end

  def has_access_to? application
    granted = self.disabled==false
    granted&= !self.expired? if granted
    granted&= application if granted
    granted&= application.enabled  if granted
    granted&= (self.super_login || self.oauth_applications.find_by_id(application.id) || self.tagged_access_to?(application)) if granted
    granted
  end

  def has_access_to_site? application: , redirect_uri:
    granted = self.disabled==false
    granted&= !self.expired? if granted
    granted&= application if granted
    granted&= application.enabled  if granted
    if granted
      site=application.sites.find_by url: redirect_uri
      granted&=!site.nil?
    end
    granted&=site.enabled if granted
    granted&= ( self.super_login || self.full_site_access.where( id: site.id).exists? ) if granted
    granted
  end

  def has_site? site
    sites.where(id: site.id).count>0
  end

  def expired?
    self.expire_at < DateTime.now
  end

  def apps_ids
   (oauth_applications.ids + tagged_access_ids).uniq
  end

  def full_access
    OauthApplication.where(id: apps_ids)
  end

  def full_site_ids
    (sites.with_app.ids + tagged_sites_access_ids + full_site_access_by_app.ids).uniq
  end
  def full_site_access
    Site.where(id: full_site_ids)
  end

  def full_site_access_by_app
    Site.joins(:oauth_applications_sites).where( 'oauth_applications_sites.oauth_application_id': apps_ids )
  end

  def tagged_access_ids
    OauthApplication.any_tag_ids self.tags
  end

  def tagged_sites_access_ids
    Site.with_app.any_tag_ids self.tags
  end

  def tagged_sites
    Site.where(id: tagged_sites_access_ids)
  end

  def tagged_access_to? application
    (application.full_tags - self.tag_list).count < application.full_tags.count
  end

  def tagged_access_to_site? site
    (site.full_tags - self.tag_list).count < site.full_tags.count
  end

  def available_tags
    ActsAsTaggableOn::Tag.where.not(id: tags.ids)
  end

end
