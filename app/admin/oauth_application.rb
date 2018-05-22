ActiveAdmin.register OauthApplication, as: "Applications" do

  config.batch_actions = false

  permit_params :name, :enabled, :redirect_uri, :external_id, :application_environment_id, user_ids: [], tag_ids: []

  index do
    column :name
    column :enabled
    column :external_id
    column :application_environment
    column :updated_at
    column 'Frontend' do |app|
      link_to 'Edit', admin_frontends_path + "?app_id=#{app.id}"
    end
    actions
  end

  filter :name
  filter :uid
  filter :users
  filter :enabled
  filter :external_id
  filter :redirect_uri
  filter :application_environment

  show do |item|
    attributes_table do
      row :name
      row :tag_list
      row :uid
      row :secret
      row :enabled
      row :redirect_uri
      row :external_id
      row :application_environment
    end
    panel 'Users with access (super login, tagged, or added to the application)' do
      table_for User.with_access_to(item) do
        column :name
        column :email
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs 'Admin Details' do
      f.input :name
      f.input :tags, :as => :check_boxes, :multiple => true, :collection => ActsAsTaggableOn::Tag.where.not(name: OauthApplication.default_tags)
      f.input :enabled
      f.input :redirect_uri
      f.input :external_id
      f.input :application_environment
      f.input :users, :as => :check_boxes
    end
    f.actions
  end
end
