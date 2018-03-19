ActiveAdmin.register User do
  permit_params :email, :disabled, :super_login, :password, :password_confirmation, :expire_at, oauth_application_ids: [], tag_ids: []

  index do
    selectable_column
    column :name
    column :email
    column :current_sign_in_at
    column :disabled
    column :super_login
    actions
  end

  filter :name
  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  filter :tags
  filter :disabled
  filter :super_login

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :disabled
      f.input :super_login
      f.input :expire_at
      f.input :tags, :as => :check_boxes, :multiple => true, :collection => @tags
      f.input :oauth_applications, :as => :check_boxes
    end
    f.actions
  end

  show do
    attributes_table do
      default_attribute_table_rows.each do |field|
        row field
      end

      row :tag_list
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
