class ApplicationEnvironment < ActiveRecord::Base

  acts_as_taggable

  has_many :oauth_applications

  def self.update_application_stage_type_tags
    all.each do |app_env|
      app_env.tag_list.add app_env.name
      app_env.save
    end
  end

end
