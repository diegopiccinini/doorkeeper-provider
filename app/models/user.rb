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
      []
    elsif self.super_login
      OauthApplication.all
    else
      self.oauth_applications
    end
  end

  def has_access_to? application
    granted =  self.disabled==false
    granted&= !self.expired? if granted
    granted&= application if granted
    granted&= application.enabled  if granted
    granted&= (self.super_login || self.oauth_applications.find_by_id(application.id)) if granted
    granted
  end

  def expired?
    self.expire_at < DateTime.now
  end
end
