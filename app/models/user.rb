class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2]
  has_and_belongs_to_many :oauth_applications
  has_many :oauth_access_grants, foreign_key: "resource_owner_id"

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
end
