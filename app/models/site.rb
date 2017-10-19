class Site < ActiveRecord::Base

  has_and_belongs_to_many :oauth_applications

  before_save :update_total_oauth_applications

  scope :central_auth_redirection,-> { where( step: 'central auth redirection' ) }

  def update_total_oauth_applications
    self.total_oauth_applications= oauth_application_ids.count
  end

  def uri
    URI(url)
  end

  def host
    uri.host
  end

  def apps
    oauth_applications.each.map { |x| x.name }.join(' | ')
  end

end
