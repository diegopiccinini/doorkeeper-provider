namespace :sites do
  desc "check sites url status and belongs"
  task check: :environment do
    OauthApplication.all.each do |a|
      puts "Application: #{a.name}"
      a.check_sites_for_redirect_uri a.redirect_uri
      block_end
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

  desc "to check only the new sites"
  task new: :environment do
    Site.where(ip: nil).each do |site|
      status site
      site_ip site
    end
  end

  desc "get duplicated sites"
  task duplicated: :environment do
    to_review=[]

    Site.central_auth_redirection.where("total_oauth_applications>1").each do |s|
      header_text "#{s.host}, ip: #{s.ip}"

      matches = []

      s.oauth_applications.each do |a|
        puts
        puts "Server: #{a.name}, created_at: #{a.created_at}"

        puts a.ip

        matches << a if a.ip==s.ip
      end
      if matches.count==1
        a=matches.first
        puts "---> #{a.name} is the right"

        join_table=OauthApplicationsSite.find_by(site: s,oauth_application: a)
        join_table.update(status: 'correct') if join_table and join_table.status!='disabled'
        OauthApplicationsSite.where(site: s).where.not(oauth_application: a).each do |incorrect|
          incorrect.update(status: 'incorrect')
        end
      else
        to_review<<s
      end
      block_end
    end

    header_text 'Applications to review' if to_review.count>0

    to_review.each do |s|

      puts "#{s.host}, ip: #{s.ip}"
      s.oauth_applications.each do |a|
        puts "\t#{a.name}\t#{a.id}"
      end

    end

    # set correct site for not duplicated apps
    Site.central_auth_redirection.where(total_oauth_applications: 1).each do |s|
      join_table=OauthApplicationsSite.find_by site: s
      join_table.update( status: 'correct') if join_table
    end

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

  def header_text text
    puts '*' * 50
    puts text
    puts '*' * 50
  end

  desc "clean redirect_uri sites"
  task clean: :environment do
    OauthApplication.where(enabled: false).all.each do |a|
      puts a.name

      if a.tidy_sites!=''
        puts "Tidy sites:"
        puts a.tidy_sites
        puts
        puts "Redirects uri:"
        puts a.redirect_uri
        puts

        a.update_sites

        a.update(enabled: true)
        puts "--> Enabled: #{a.name}"

      else
        puts ">>> no tidy sites to enable and update"
      end

    end
  end

  desc "exports sites"
  task export: :environment do
    puts %w(host status ip server).join(',')
    Site.order(:status,:url).each do |s|
      puts [s.host,s.status,s.ip,s.apps].join(',')
    end
  end

  desc "exclude to the automatic enabling"
  task :exclude, [:site] => :environment do |t,args|

    sites=Site.where("url like ?","%#{args.site}%").all
    ids=[]
    s_ids=[]
    sites.each do |site|
      puts "#{site.url}, #{site.step}"
      site.oauth_applications.each do |a|
        join_table=OauthApplicationsSite.find_by site: site, oauth_application: a
        ids<< join_table.id
        puts "\t#{join_table.id}, #{a.name}, #{join_table.status}"
      end
    end

    if !ids.empty?
      puts "Write:"
      puts "\t'd' and the list of apps ids with space separation to disable, sample: d 432 342"
      puts "\t'c' and the list of apps ids to set as correct (will be enabled in the clean process), sample: c 33 41"
      puts "\t'da' for disable all"
      puts "\t'ea' for enable all"
      puts "\t'x' exit without changes"

      selected = STDIN.gets.chomp

      selected=selected.split
      s_ids=selected[1..-1].map { |x| x.to_i } if selected.size>1
      diff_ids = s_ids - ids

      case selected.first
      when 'da'
        app_site_update status: 'disabled', ids: ids
      when 'ea'
        app_site_update status: 'correct', ids: ids
      when 'd'
        raise "The #{diff_ids.to_s} are not in the list" if !diff_ids.empty?
        app_site_update status: 'disabled', ids: s_ids
      when 'c'
        raise "The #{diff_ids.to_s} are not in the list" if !diff_ids.empty?
        app_site_update status: 'correct', ids: s_ids
      when 'x'
        puts "No changes will be applied"
      else
        puts "Invalid option no changes will be applied"
      end
    end
  end

  def app_site_update status: , ids:
    OauthApplicationsSite.where( id: ids).each { |oa| oa.update(status: status) }
    puts "#{ids.to_s} updated to #{status}"
  end
end
