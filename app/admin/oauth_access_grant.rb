ActiveAdmin.register OauthAccessGrant, as: "Logs" do

  menu parent: 'Users', priority: 4

  config.batch_actions = false

  index as: :blog do

    title do |l|
      span l.redirect_uri , class: 'c-button c-button--ghost'
    end

    body do |l|
      span l.created_at
      span l.user_name
    end
  end

end

