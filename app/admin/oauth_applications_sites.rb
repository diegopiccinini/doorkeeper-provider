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
    actions
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

