ActiveAdmin.register Site do

  menu parent: 'Sites', priority: 1

  permit_params :excluded, user_ids: [], tag_ids: []

  config.batch_actions = false
  config.sort_order = 'url_asc'

  index do
    column :url
    column :enabled
    column :applications
    actions do |site|
      span ' | '
      item 'Users', admin_site_users_path + "?site_id=#{site.id}"
    end
  end

  filter :url
  filter :status
  filter :step
  filter :ip
  filter :excluded

  show do |item|
    attributes_table do
      row :url
      row :tag_list
      row :excluded
    end

    panel 'Application(s) (the normal is to belongs to only one)' do
      table_for item.oauth_applications do
        column :name
        column :external_id
        column :application_environment
        column :enabled
      end
    end

    panel 'Users with access (super login, tagged, or added to the application)' do
      table_for User.with_access_to_site(item) do
        column :name
        column :email
        column :super_login
        column :disabled
        column :expired?
      end
    end
  end

  form do |f|

    panel "Site Details" do
      table_for object do
        column :url
        column :tag_list
        column :owner_apps
      end
    end

    inputs 'Change Details' do
      input :excluded
      input :tags, :as => :check_boxes, :multiple => true, :collection => @tags
      input :users, :as => :check_boxes
    end

    f.actions
  end
end
