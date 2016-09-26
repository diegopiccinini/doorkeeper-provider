ActiveAdmin.register User do
  permit_params :email, oauth_application_ids: []

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  filter :oauth_applications

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :oauth_applications, :as => :check_boxes
    end
    f.actions
  end
end
