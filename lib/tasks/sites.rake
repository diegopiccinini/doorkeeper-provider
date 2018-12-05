namespace :sites do

  desc "run all tasks to clean and syncro"
  task all: :environment do
    %w(reset_all status enable black_list clean_duplication).each do |t|
      Rake::Task["sites:#{t}"].invoke
    end
  end

  desc "delete all not callback sites, create and clean relationships"
  task reset_all: :environment do

    ApplicationEnvironment.update_application_stage_type_tags

    Site.where.not('url LIKE ?','%callback%').each { |s| s.delete }

    OauthApplication.where(sync_excluded: false).all.each do |a|
      a.create_sites
      a.clean_sites
    end

    puts "Total sites: #{Site.count}"

  end

  desc "List duplicated sites"
  task list_duplicated: :environment do
    list_duplicated_sites
  end

  def list_duplicated_sites
    puts "Duplicated sites:"
    duplicated=OauthApplicationsSite.select("site_id, oauth_application_id").group(:site_id).having("count(oauth_application_id)>1")
    duplicated.each do |os|
      os_app=OauthApplicationsSite.find_by site_id: os.site_id , oauth_application_id: os.oauth_application_id
      puts "Site: #{os_app.site.url}"
      puts "Status: #{os_app.status}"
      puts "Application: #{os.oauth_application.external_id}"
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
    Site.backend.all.each do |site|
      status site
    end
  end

  desc "set ip to sites"
  task ip: :environment do
    Site.all.each do |s|
      site_ip s
    end
  end


  desc "enable check new sites status"
  task new_sites_status: :environment do

    sites=[]
    OauthApplicationsSite.new_site.each do |app_site|
      sites<<app_site.site
      app_site.update( status: OauthApplicationsSite::STATUS_TO_CHECK )
    end
    sites=sites.uniq

    sites.each do |site|
      status site
      site_ip site
    end

    Rake::Task["sites:enable"].invoke
  end

  desc "enable 302 and unique sites"
  task enable: :environment do

    puts
    puts "Enabling non duplicated sites with 302 redirection"

    OauthApplicationsSite.to_check.each do |os|
      site=os.site
      app=os.oauth_application

      if site.step==Site::STEP_CENTRAL_AUTH_302
        enable os
      else
        puts "\t--> Site added to black list #{site.url}"
        site.step= Site::STEP_BLACK_LIST
        site.save
        black_list=BlackList.find_or_create_by site: site
        black_list.times+=1
        black_list.log||="Init:\n"
        black_list.log+="App: #{app.external_id} black listed at #{site.updated_at}\n"
        black_list.log+="Status: #{site.status}, ip #{site.ip}\n"
        black_list.save
        os.update( status: OauthApplicationsSite::STATUS_BLACK_LIST )
      end
      puts
    end
  end

  def enable os
    app=os.oauth_application
    if app.enabled
      puts "\tApp: #{app.name} site: #{os.site.url}, it is ok and has been enabled before"
    else
      puts "\t--> Enabling app: #{app.name} site: #{os.site.url}"
      app.update( enabled: true)
    end
    os.site.black_list.delete unless os.site.black_list.nil?
    os.update( status: OauthApplicationsSite::STATUS_ENABLED )
  end

  def disabling_duplicated_incorrect os

    if os.count_duplicated_incorrect>0
      OauthApplicationsSite.duplicated_incorrect.where( site: os.site).each do |o_incorrect|
        app=o_incorrect.oauth_application
        puts "Disabling duplicated site #{os.site.url} in #{app.external_id}"
        app.delete_redirect_uri os.site
        o_incorrect.update( status: OauthApplicationsSite::STATUS_DISABLED_DUCPLICATED_INCORRECT )
      end
    else
      puts "Incorrect applications not found for site #{os.site.url}"
    end

  end

  desc "clean duplication"
  task clean_duplication: :environment do
    puts "Cleaning duplication"

    OauthApplicationsSite.duplicated_correct.each do |os|
      if os.count_correct_by_site==1
        enable os
        disabling_duplicated_incorrect os
      end
    end
    stats= OauthApplicationsSite.group(:status).count()
    puts
    puts "Stats:"
    stats.each_pair do |k,v|
      puts "\t#{k}:\t#{v}"
    end
  end

  desc "list all sites in a black list to clean"
  task black_list: :environment do
    puts "Sites in black list:"

    i=0
    OauthApplicationsSite.black_list.each do |os|
      next if os.site.url.include?('unknown404')
      next if os.site.url.include?('localhost')
      puts os.site.url
      puts "\tApplication: #{os.oauth_application.external_id}"
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
