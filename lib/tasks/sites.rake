require 'uri'
require 'faraday'

namespace :sites do
  desc "check sites url status and belongs"
  task check: :environment do
    OauthApplication.all.each do |a|
      a.redirect_uri.split.each do |site|
        s=Site.find_or_create_by( url: site[0..-('/callback'.length + 1)])
        a.sites << s unless a.sites.find s.id
      end
    end
  end

  desc "get response status"
  task status: :environment do
    Site.where(step: nil).each do |site|
      puts site.url
      uri = URI(site.url)
      conn=Faraday.new( url: uri.scheme + '://' + uri.host )
      step='bad response'
      begin
        response=conn.get uri.path
        puts response.status

        if response.status==302
          if response.headers['location'].start_with?'https://auth.bookingbug.com'
            step='central auth redirected'
          else
            step='no central auth redirect'
          end
        end

        site.status=response.status
      rescue

        site.status=443
        step='site unavailable'
      end

      site.step=step
      site.save
      puts "Applications #{site.oauth_applications.count}"
      puts site.step
      puts '-' * 30
    end
  end

end
