ActiveAdmin.register User do
  permit_params :email, :disabled, :password, :password_confirmation, oauth_application_ids: []

  index do
    selectable_column
    column :name
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :disabled
    actions
  end

  filter :name
  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  filter :oauth_applications

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :disabled
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
