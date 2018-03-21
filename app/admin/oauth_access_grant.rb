ActiveAdmin.register OauthAccessGrant, as: "Logs" do

  config.batch_actions = false

  index do
    column :redirect_uri
    column :created_at
    column :expires_in
    column :user_name
    actions
  end

end
