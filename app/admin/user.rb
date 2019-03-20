ActiveAdmin.register User do

  menu parent: 'Users', priority: 1

  config.batch_actions = false

  permit_params :email, :disabled, :super_login, :password, :password_confirmation, :expire_at, tag_ids: [], oauth_application_ids: []

  index do
    column :name
    column :email
    column :current_sign_in_at
    column :expire_at
    column :disabled
    column :super_login
    actions do |u|
      span ' | '
      link_to 'Sites', admin_user_sites_path + "?user_id=#{u.id}", class: 'c-button c-button--ghost-success'
    end
  end

  filter :name
  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  filter :tags
  filter :disabled
  filter :expire_at
  filter :super_login

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :tags, :as => :check_boxes, :multiple => true, :collection => @tags
      f.input :password
      f.input :password_confirmation
      f.input :disabled
      f.input :super_login
      f.input :expire_at
      f.input :oauth_applications, :as => :check_boxes, :multiple => true, :collection => OauthApplication.order(name: :asc)
    end
    f.actions
  end

  show do |item|

    attributes_table do

      row :email
      row :name
      row :first_name
      row :last_name
      row :tag_list
      row :last_sign_in_at
      row :last_sign_in_ip
      row :updated_at
      row :created_at
      row :expire_at
      row :super_login
      row :disabled

      row :enabled_application_names
      row :disabled_application_names

    end

    panel 'Sites DIRECT access' do
      table_for item.sites.with_app.uniq do
        column :url
        column :applications
        column :tag_list do |site|
          (site.full_tags ).join(" | ")
        end
      end
    end

    panel 'Sites access by TAG' do
      table_for item.tagged_sites do
        column :url
        column :applications
        column :tag_list do |site|
          (site.full_tags ).join(" | ")
        end
      end
    end

    panel 'Sites access APPLICATION' do
      table_for item.full_site_access_by_app.uniq do
        column :url
        column :applications
        column :tag_list do |site|
          (site.full_tags ).join(" | ")
        end
      end
    end
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
