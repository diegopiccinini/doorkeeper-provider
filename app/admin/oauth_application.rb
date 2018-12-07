ActiveAdmin.register OauthApplication, as: "Applications" do

  config.batch_actions = false

  permit_params :name, :enabled, :redirect_uri, :external_id, :sync_excluded, :application_environment_id, user_ids: [], tag_ids: []

  index do
    column :name
    column :enabled
    column :external_id
    column :application_environment
    column :updated_at
    actions defaults: false do |app|
      item 'Frontend', admin_frontends_path + "?app_id=#{app.id}"
      span ' | '
      item 'View', admin_application_path(app)
      span ' | '
      item 'Edit', edit_admin_application_path(app)
      span ' | '
      item 'Update Sites', update_sites_admin_application_path(app)
    end
  end

  filter :name
  filter :uid
  filter :users
  filter :enabled
  filter :external_id
  filter :redirect_uri
  filter :application_environment
  filter :sync_excluded

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
      row :sync_excluded
    end
    panel 'Sites' do
      table_for item.sites do
        column :url
        column :step
        column :status
        column "Check Status" do |site|
          span OauthApplicationsSite.find_by( site: site, oauth_application: item).status
        end
      end
    end
    active_admin_comments
  end

  member_action :update_sites, method: :get do
    resource.create_sites
    resource.clean_sites

    redirect_to resource_path, notice: "Sites Updated!"
  end

  form do |f|
    f.inputs 'Admin Details' do
      f.input :name
#      f.input :tags, :as => :check_boxes, :multiple => true, :collection => ActsAsTaggableOn::Tag.where.not(name: OauthApplication.default_tags)
      f.input :enabled
      f.input :redirect_uri
      f.input :external_id
      f.input :sync_excluded
      f.input :application_environment
      f.input :users, :as => :check_boxes
    end
    f.actions
  end
end
