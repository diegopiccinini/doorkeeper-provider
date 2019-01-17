
namespace :user_app do

  desc "list user application association"
  task list: :environment do

    f =File.new 'tmp/user_app_list.csv', 'w'
    line = %w(user.name user.email user.expire_at user.disabled a.external_id a.name a.enabled environment.name multitenant)
    f.puts line.join("\t")
    User.order(name: :asc).all.each do |user|
      user.oauth_applications.order(external_id: :asc).each do |a|
        line = [user.name, user.email, user.expire_at, user.disabled, a.external_id, a.name, a.enabled, a.application_environment.name, a.probably_multitenant?]
        f.puts line.join("\t")
      end
    end
    f.close
  end

  desc "list user application by tags"
  task by_tags: :environment do

    f =File.new 'tmp/user_app_by_tags.csv', 'w'
    line = %w(user.name user.email user.expire_at user.disabled tags a.external_id a.name a.enabled environment.name multitenant)
    f.puts line.join("\t")
    User.order(name: :asc).all.each do |user|

      next if user.tag_list.empty?
      OauthApplication.where(id: user.tagged_access_ids).order(external_id: :asc).each do |a|
        line = [user.name, user.email, user.expire_at, user.disabled, user.tag_list.join(' | '), a.external_id, a.name, a.enabled, a.application_environment.name, a.probably_multitenant?]
        f.puts line.join("\t")
      end

    end
    f.close
  end

end
