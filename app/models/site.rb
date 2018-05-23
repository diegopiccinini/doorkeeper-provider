require 'faraday'

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

  def host_url
    self.uri.scheme + '://' + self.uri.host
  end


  def apps
    oauth_applications.each.map { |x| x.name }.join(' | ')
  end

  def conn
    Faraday.new( url: self.host_url )
  end

  def check

    self.step='bad response'
    begin
      response=conn.get do |req|
        req.url uri.path
        req.options.timeout=5
        req.options.open_timeout=2
      end

      if response.status==302
        self.step='no central auth redirection'
        if response.headers['location'].start_with?("https://#{ENV['HOST']}")
          self.step='central auth redirection'
          clean_duplication response.headers['location']
        else
          delete_in_apps
        end
      end
      self.status=response.status
    rescue
      self.status=443
      self.step='site unavailable'
      delete_in_apps
    end

    self.save
  end

  def delete_in_apps

    oauth_applications.each do |a|
      a.delete_redirect_uri self
    end

  end

  def clean_duplication location

    if oauth_applications.count>1
      client_id=location["https://#{ENV['HOST']}/oauth/authorize/client_id=".size .. (location.index("&redirect_uri=") - 1)]
      oauth_applications.each do |a|
        if a.uid==client_id
          a.update( enabled: true)
          puts "\t--> The correct one is #{a.external_id}"
          puts
          # else
          # a.delete_redirect_uri(self)
          # don't delete the application wait for puppet
        end
      end
    end
  end

  def set_ip
    update(ip: get_ip)
  end

  def get_ip
    begin
      IPSocket.getaddress(self.host)
    rescue SocketError
      false
    end
  end
end
