module WelcomeHelper
  def callback_name(uri)
    name = URI(uri).host
    name.include?('.') ? name.split('.').first : name
  end
end
