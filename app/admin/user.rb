ActiveAdmin.register User do

  menu parent: 'Users', priority: 1

  config.batch_actions = false

  permit_params :email, :disabled, :super_login, :password, :password_confirmation, :expire_at, tag_ids: []

  index do
    column :name
    column :email
    column :current_sign_in_at
    column :expire_at
    column :disabled
    column :super_login
    actions do |u|
      span ' | '
      item 'Sites', admin_user_sites_path + "?user_id=#{u.id}"
    end
  end

  filter :name
  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  filter :tags
  filter :disabled
  filter :expire_at
  filter :super_login

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :tags, :as => :check_boxes, :multiple => true, :collection => @tags
      f.input :password
      f.input :password_confirmation
      f.input :disabled
      f.input :super_login
      f.input :expire_at
    end
    f.actions
  end

  show do
    attributes_table do

      row :email
      row :name
      row :first_name
      row :last_name
      row :tag_list
      row :last_sign_in_at
      row :last_sign_in_ip
      row :updated_at
      row :created_at
      row :expire_at
      row :super_login
      row :disabled

      row :enabled_application_names
      row :disabled_application_names

    end

  end

  controller do
    def update
      if params[:user][:password].blank?
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end
      super
    end
  end
end
