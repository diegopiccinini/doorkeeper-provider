ActiveAdmin.register OauthApplicationsSite do

  menu parent: 'Sites', priority: 3

  permit_params :status

  config.batch_actions = false

  filter :status
  filter :site_url_contains
  filter :oauth_application_name_contains, label: 'Application Name Contains'
  filter :created_at
  filter :updated_at

  index do
    column :site
    column :oauth_application, as: 'Application'
    column :status
    column :updated_at
    actions do |app_site|
      span ' | '
      if app_site.status==OauthApplicationsSite::STATUS_ENABLED
        link_to 'Disable', disable_admin_oauth_applications_site_path(app_site), class: 'c-button u-small c-button--warning'
      else
        link_to 'Enable', enable_admin_oauth_applications_site_path(app_site), class: 'c-button u-small c-button--success'
      end
    end
  end

  member_action :enable, method: :get do
    resource.enable
    redirect_to resource_path, notice: "Site #{resource.site.url} enabled!"
  end

  member_action :disable, method: :get do
    resource.disable email: current_admin_user.email
    redirect_to resource_path, notice: "Site #{resource.site.url} disabled!"
  end

  form do |f|

    panel "Application Site Details" do
      table_for object do
        column :site_url
        column :application_name
      end
    end

    inputs 'Change Details' do
      input :status
    end

    f.actions
  end

end

