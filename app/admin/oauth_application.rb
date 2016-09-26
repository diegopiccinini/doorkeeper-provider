ActiveAdmin.register OauthApplication do
  permit_params :name, user_ids: []

  index do
    selectable_column
    id_column
    column :name
    column :redirect_uri
    actions
  end
  filter :name
  filter :users

  form do |f|
    f.inputs 'Admin Details' do
      f.input :name
      f.input :users, :as => :check_boxes
    end
    f.actions
  end
end
