ActiveAdmin.register OauthApplication do
  permit_params :name, :redirect_uri, user_ids: []

  index do
    selectable_column
    id_column
    column :name
    column :redirect_uri
    actions
  end
  filter :name
  filter :users

  show do
    attributes_table do
      row :name
      row :uid
      row :secret
      row :redirect_uri
    end
    panel 'Users' do
      table_for oauth_application.users.where(super_login: false) do
        column :name
        column :email
        column :disabled
      end
    end
    panel 'Users who can login to every applications' do
      table_for User.where(super_login: true) do
        column :name
        column :email
        column :disabled
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs 'Admin Details' do
      f.input :name
      f.input :redirect_uri
      f.input :users, :as => :check_boxes
    end
    f.actions
  end
end
