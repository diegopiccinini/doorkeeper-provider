ActiveAdmin.register OauthApplication do
  permit_params :name, :enabled, :redirect_uri, :external_id, :application_environment_id, user_ids: []

  index do
    selectable_column
    id_column
    column :name
    column :redirect_uri
    column :enabled
    column :external_id
    column :application_environment
    actions
  end
  filter :name
  filter :uid
  filter :users
  filter :enabled
  filter :external_id
  filter :application_environment

  show do
    attributes_table do
      row :name
      row :uid
      row :secret
      row :enabled
      row :redirect_uri
      row :external_id
      row :application_environment
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
      f.input :enabled
      f.input :redirect_uri
      f.input :external_id
      f.input :application_environment
      f.input :users, :as => :check_boxes
    end
    f.actions
  end
end
