ActiveAdmin.register OauthApplicationsSite do

  permit_params :status

  config.batch_actions = false

  filter :status
  filter :site_url_contains
  filter :oauth_application_name_contains, label: 'Application Name Contains'

  index do
    column :site
    column :oauth_application, as: 'Application'
    column :status
    actions do |app_site|
      span ' | '
      if app_site.status==OauthApplicationsSite::STATUS_ENABLED
        item 'Disable', disable_admin_oauth_applications_site_path(app_site)
      else
        item 'Enable', enable_admin_oauth_applications_site_path(app_site)
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

