ActiveAdmin.register OauthApplication, as: "Applications" do

  menu parent: 'Applications', priority: 1

  config.batch_actions = false

  permit_params :name, :enabled, :redirect_uri, :external_id, :sync_excluded, :enabled_to_everybody, :application_environment_id, :multitenant, tag_ids: [], user_ids: []

  index do
    column :name
    column :enabled
    column :external_id
    column :application_environment
    column :updated_at
    actions do |app|
      span ' | '
      a 'Update Sites', update_sites_admin_application_path(app), class: 'c-button c-button--ghost-success'
      a 'Frontend', admin_frontends_path + "?app_id=#{app.id}", class: 'c-button c-button--ghost'
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
  filter :multitenant
  filter :enabled_to_everybody

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
      row :multitenant
      row :enabled_to_everybody
    end

    panel 'Users Direct Association' do
      table_for item.users.order(name: :asc) do
        column :name
        column :email
        column :expired?
        column :disabled
        column :super_login
      end
    end

    panel 'Users Associated by Tag' do
      table_for item.tagged_users.order(name: :asc) do
        column :name
        column :email
        column :expired?
        column :disabled
        column :super_login
        column :tag_list do |user|
          (user.tag_list & item.full_tags ).join(" | ")
        end
      end
    end

    panel 'Sites' do
      table_for item.sites do
        column :url
        column :step
        column :status
        column :updated_at do |site|
          span OauthApplicationsSite.find_by( site: site, oauth_application: item).updated_at
        end
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
    CheckSitesStatusJob.perform_async resource.id
    redirect_to resource_path, notice: "Sites Updated!"
  end

  form do |f|
    f.inputs 'Admin Details' do
      f.input :name
      f.input :tags, :as => :check_boxes, :multiple => true, :collection => ActsAsTaggableOn::Tag.where.not(name: OauthApplication.default_tags)
      f.input :enabled
      f.input :redirect_uri
      f.input :external_id
      f.input :sync_excluded
      f.input :multitenant
      f.input :enabled_to_everybody
      f.input :application_environment
      f.input :users, :as => :check_boxes, :multiple => true, :collection => User.order(name: :asc)
    end
    f.actions
  end
end
