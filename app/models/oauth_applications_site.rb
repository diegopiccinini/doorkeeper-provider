class OauthApplicationsSite < ActiveRecord::Base
  belongs_to :site
  belongs_to :oauth_application

  scope :to_check,-> { where( status: STATUS_TO_CHECK ) }
  scope :black_list,-> { where( status: STATUS_BLACK_LIST ) }
  scope :duplicated_correct,-> { where( status: STATUS_DUPLICATED_CORRECT ) }
  scope :duplicated_incorrect,-> { where( status: STATUS_DUPLICATED_INCORRECT ) }
  scope :enabled,-> { where( status: STATUS_ENABLED ) }
  scope :new_site,-> { where( status: STATUS_NEW_SITE ) }
  scope :site_url_contains, -> (url) { joins(:site).where("url LIKE ?","%#{url}%") }
  scope :oauth_application_name_contains, -> (name) { joins(:oauth_application).where("name LIKE ?","%#{name}%") }

  STATUS_NEW_SITE='new site'
  STATUS_TO_CHECK='to check'
  STATUS_DUPLICATED_CORRECT='duplicated correct'
  STATUS_DUPLICATED_INCORRECT='duplicated incorrect'
  STATUS_CORRECT='correct'
  STATUS_ENABLED='enabled'
  STATUS_BLACK_LIST = 'black list'
  STATUS_DISABLED_DUCPLICATED_INCORRECT = 'duplicated incorrect disabled'

  def count_duplicated_incorrect
    OauthApplicationsSite.duplicated_incorrect.where( site: site).count
  end

  def count_correct_by_site
    OauthApplicationsSite.duplicated_correct.where( site: site).count
  end

  def self.applications_by_site_ids site_ids
    app_ids=where( site_id: site_ids).map do |app_site|
      app_site.oauth_application_id
    end.uniq
    OauthApplication.where(id: app_ids)
  end

  def self.sites_by_application_ids app_ids
    site_ids=where( oauth_application_id: app_ids).map do |app_site|
      app_site.site_id
    end.uniq
    Site.where(id: site_ids)
  end

  def site_url
    site.url
  end

  def application_name
    oauth_application.name
  end

end
