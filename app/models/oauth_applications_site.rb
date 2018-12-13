class OauthApplicationsSite < ActiveRecord::Base
  attr_accessor :output

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
  STATUS_DISABLED_MANUALLY='disabled manually'

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

  def check
    if site.step==Site::STEP_CENTRAL_AUTH_302
      enable
    else
      add_to_black_list
    end
  end

  def add_to_black_list
    site.update step: Site::STEP_BLACK_LIST
    write_black_list_log
    update( status: OauthApplicationsSite::STATUS_BLACK_LIST )
  end

  def write_black_list_log
    black_list=BlackList.find_or_create_by site: site
    black_list.times+=1
    black_list.log||="Init:\n"
    black_list.log+="Application: #{oauth_application.external_id} black listed at #{site.updated_at}\n"
    black_list.log+="Status: #{site.status}, ip #{site.ip}\n"
    black_list.save
  end

  def enable
    oauth_application.update( enabled: true)
    site.black_list.delete unless site.black_list.nil?
    update( status: OauthApplicationsSite::STATUS_ENABLED )
  end

  def disable email: nil

    black_list=BlackList.find_or_create_by site: site
    black_list.times+=1
    black_list.log||="Init:\n"
    black_list.log+="Application: #{oauth_application.external_id} disabled manually.\n"
    black_list.log+="By: #{email}.\n" unless email.nil?
    black_list.log+="At: #{Time.now.to_s}\n"
    black_list.save

    update( status: OauthApplicationsSite::STATUS_DISABLED_MANUALLY )

  end


end
