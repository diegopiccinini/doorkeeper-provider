module WelcomeHelper

  def callback_name uri
    uri.include?('bookingbug/callback') ? backend_name(uri) : frontend_name(uri)
  end

  def backend_name uri
    name = URI(uri).host
    name.include?('.') ? name.split('.').first : name
  end

  def frontend_name uri
    name = URI(uri).query['frontend_app']
    name.include?('.') ? name.split('.').first : name
  end
end
