module ApplicationHelper
  def first_domain
    ENV['CUSTOM_DOMAIN_FILTER'].split.first.capitalize
  end
end
