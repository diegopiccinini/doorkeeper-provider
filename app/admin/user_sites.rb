ActiveAdmin.register_page "User Sites" do

  menu parent: 'Users', priority: 2

  page_action :edit, method: :get do
    sites=Site

    session[:site_name_filter]=params[:site_name] if params[:site_name]
    sites=sites.url_contains(session[:site_name_filter]) if session[:site_name_filter]

    sites=sites.order(:url).limit(30)
    user=User.find(params[:user_id])
    render partial: 'edit', locals: { user: user, sites: sites }
  end

  page_action :filter, method: :post do
    session[:user_name_filter]=params[:user_name]
    redirect_to admin_user_sites_path
  end

  page_action :clear_edit_filter, method: :get do
    session.delete(:site_name_filter)
    redirect_to admin_user_sites_edit_path + "?user_id=#{params[:user_id]}"
  end

  page_action :clear_filter, method: :get do
    session.delete(:user_name_filter)
    redirect_to admin_user_sites_path
  end

  content do
    users=User

    if session[:user_name_filter]
      users=users.where( "name LIKE ?", "%#{session[:user_name_filter]}%")
    end

    users=users.order(:name).limit(10)

    render partial: 'user_sites', locals: { users: users }
  end

  sidebar :filters, partial: 'filters'
end
