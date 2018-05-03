class User < ActiveRecord::Base

  acts_as_taggable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2]
  has_and_belongs_to_many :oauth_applications
  has_many :oauth_access_grants, foreign_key: "resource_owner_id", dependent: :delete_all
  has_many :oauth_access_tokens, foreign_key: "resource_owner_id", dependent: :delete_all

  before_save { self.expire_at = DateTime.now + 180 unless self.expire_at }

  scope :access_with_tag, -> (oauth_application) { tagged_with(oauth_application.full_tags, any: true).where(disabled: false) }

  def self.with_access_to oauth_application
    uids= where( super_login: true, disabled: false ).ids
    uids+= access_with_tag(oauth_application).ids
    uids+= oauth_application.users.where(disabled: false).ids
    where( id: uids )
  end


  def to_s
    email
  end

  def self.from_omniauth(auth)
    if auth[:info][:email].split('@').last == ENV['CUSTOM_DOMAIN_FILTER']
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
      OauthApplication.where("id < -100000")
    elsif self.super_login
      OauthApplication
    else
      full_access
    end
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
    granted =  self.disabled==false
    granted&= !self.expired? if granted
    granted&= application if granted
    granted&= application.enabled  if granted
    granted&= (self.super_login || self.oauth_applications.find_by_id(application.id) || self.tagged_access_to?(application)) if granted
    granted
  end

  def expired?
    self.expire_at < DateTime.now
  end

  def full_access
    apps_ids=oauth_applications.ids + tagged_access_ids
    OauthApplication.where(id: apps_ids.uniq)
  end

  def tagged_access_ids
    OauthApplication.any_tag_ids self.tags
  end

  def tagged_access_to? application
    (application.full_tags - self.tag_list).count < application.full_tags.count
  end

  def available_tags
    ActsAsTaggableOn::Tag.where.not(id: tags.ids)
  end

end
