class ApplicationEnvironment < ActiveRecord::Base

  acts_as_taggable

  has_many :oauth_applications

  def self.update_application_stage_type_tags
    all.each do |app_env|
      app_env.tag_list.add app_env.name
      app_env.save
    end
  end

  def self.by_sites sites
    sites.map do |s|
      s.oauth_applications.map { |app| app.application_environment }
    end.flatten.uniq
  end

end
