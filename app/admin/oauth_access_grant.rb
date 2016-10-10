ActiveAdmin.register OauthAccessGrant do

  index do
    selectable_column
    id_column
    column :redirect_uri
    column :created_at
    column :expires_in
    column :user_name
    actions
  end

end
