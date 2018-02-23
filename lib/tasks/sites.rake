namespace :sites do

  desc "delete all sites and create new list"
  task reset_all: :environment do

    OauthApplicationsSite.all.each { |x| x.delete }
    Site.all { |s| s.delete }

    OauthApplication.all.each do |a|
      a.create_sites
    end

    puts "Sites created: #{Site.count}"

  end

  desc "List duplicated sites"
  task list_duplicated: :environment do
    list_duplicated_sites
  end

  def list_duplicated_sites
    puts "Sites duplicated:"
    duplicated=OauthApplicationsSite.select("site_id, oauth_application_id").group(:site_id).having("count(oauth_application_id)>1")
    duplicated.each do |os|
      os_app=OauthApplicationsSite.where(site_id: os.site_id , oauth_application_id: os.oauth_application_id).first
      os_app.status="Duplicated"
      os_app.save
      os.site.check
      puts "Site: #{os.site.url}"
      apps=os.site.oauth_applications.map { |a| a.external_id }
      puts "Aplications: #{apps.join(' ')}"
      puts
    end
  end

  def status site
    puts site.url
    site.check
    puts "Applications #{site.oauth_applications.count}"
    puts site.step
    block_end
  end

  def site_ip s
    s.ip=ip(s.host)
    puts "Site: #{s.host}, ip: #{s.ip}"
    s.save
  end

  desc "get response status"
  task status: :environment do
    Site.all.each do |site|
      status site
    end
  end

  desc "set ip to sites"
  task ip: :environment do
    Site.all.each do |s|
      site_ip s
    end
  end

  desc "enable 302 and unique sites"
  task enable: :environment do
    OauthApplicationsSite.where(status: 'to check').each do |os|
      site=os.site
      app=os.oauth_application

      if site.step=='central auth redirection'
        if app.enabled
          puts "\tApp: #{app.name} site: #{site.url}, it is ok and has been enabled before"
        else
          puts "\t--> Enabling app: #{app.name} site: #{site.url}"
          app.update( enabled: true)
        end
      else
        puts "\t--> Site added to black list #{site.url}"
        site.step='black list'
        site.save
        app.delete_redirect_uri site
      end
      puts
    end
  end

  desc "list all sites in a black list to clean"
  task black_list: :environment do
    puts "Sites in black list:"

    i=0
    Site.where(step: 'black list').each do |site|
      next if site.url.include?('unknown404')
      next if site.url.include?('localhost')
      apps=site.oauth_applications.map { |x| x.external_id }
      puts site.url
      puts "\tapps: #{apps.join("\t")}"
      puts
      i+=1
    end
    puts "Total sites in black list: #{i}"
  end

  def ip name
    begin
      IPSocket.getaddress(name)
    rescue SocketError
      false
    end
  end

  def block_end
    puts '-' * 50
    puts
  end

end
