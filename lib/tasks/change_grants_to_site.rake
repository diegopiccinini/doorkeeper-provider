namespace :change_grants_to_site do

  desc "run all tasks"
  task all: :environment do
    %w(migrate_tags add_sites_to_users compare_grants).each do |t|
      Rake::Task["change_grants_to_site:#{t}"].invoke
    end
  end

  desc "migrate tags from application to sites"
  task migrate_tags: :environment do
    puts "Migrate tags to site:"
    puts
    OauthApplication.all.each do |app|
      tags=app.full_tags
      puts "App: #{app.external_id}"
      app.sites.each do |s|
        puts "Site: #{s}, tags: #{tags}"
        s.tag_list.add tags
        s.save
      end
      puts
    end
  end

  desc "add sites to users when they have directly grants to applications"
  task add_sites_to_users: :environment do
    puts "Add sites to users"
    User.all.each do |user|
      puts user.email
      user.oauth_applications.each do |a|
        a.sites.each do |s|
          puts "\tadding site #{s.url}"
          user.sites<< s unless user.sites.include?s
        end
      end
      user.save
    end
  end

  desc "compare user grants application vs site"
  task compare_grants: :environment do
    puts "Compare application grants vs site grants"
    cols=%w(email old_sites new_sites old_new_diff new_old_diff)
    puts cols.join("\t")
    no_match=[]
    User.all.each do |user|
      site_ids = []
      user.full_access.each do |app|
        site_ids+= app.sites.ids
      end

      site_ids+=Site.ids if user.super_login

      user_site_with_tag_ids=Site.tagged_with(user.tag_list, any: true).ids
      user_site_with_tag_ids+=user.sites.ids
      user_site_with_tag_ids+=Site.ids if user.super_login

      site_ids=site_ids.uniq
      user_site_with_tag_ids=user_site_with_tag_ids.uniq

      row=[user.email]
      row<<site_ids.count
      row<<user_site_with_tag_ids.count
      diff1=(site_ids - user_site_with_tag_ids).count
      row<<diff1
      diff2=(user_site_with_tag_ids - site_ids ).count
      row<<diff2

      puts row.join("\t")
      no_match<< user.email if (diff1+diff2)>0

    end

    puts "No match users"
    puts no_match.join("\t")
  end
end
