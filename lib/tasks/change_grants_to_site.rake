namespace :change_grants_to_site do

  desc "run all tasks"
  task all: :environment do
    %w(migrate_tags).each do |t|
      Rake::Task["sites:#{t}"].invoke
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

  desc "compare user grants application vs site"
  task compare_grants: :environment do
    puts "Compare application grants vs site grants"
    puts
    User.all.each do |user|
      puts "User: #{user.email}"
      site_ids = []
      user.full_access.each do |app|
        site_ids+= app.sites.ids
      end

      site_ids+=Site.ids if user.super_login

      user_site_with_tag_ids=Site.tagged_with(user.tag_list).ids
      user_site_with_tag_ids+=Site.ids if user.super_login

      site_ids=site_ids.uniq
      user_site_with_tag_ids=user_site_with_tag_ids.uniq

      puts "with app not with site tags"
      puts (site_ids - user_site_with_tag_ids).count

      puts "with site tags not in apps"
      puts (user_site_with_tag_ids - site_ids ).count

      puts
    end
  end
end
