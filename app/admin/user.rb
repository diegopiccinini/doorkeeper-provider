ActiveAdmin.register User do
  permit_params :email, :disabled, :super_login, :password, :password_confirmation, :expire_at, oauth_application_ids: []

  index do
    selectable_column
    column :name
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :disabled
    column :super_login
    actions
  end

  filter :name
  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  filter :oauth_applications
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
      f.input :oauth_applications, :as => :check_boxes
    end
    f.actions
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
