ActiveAdmin.register_page "Site Users" do

  menu false

  page_action :filter, method: :post do
    session[:user_name_filter]=params[:user_name]
    redirect_to admin_site_users_path
  end

  page_action :clear_filter, method: :get do
    session.delete(:user_name_filter)
    redirect_to admin_site_users_path
  end

  page_action :add, method: :get do
    user=User.find params[:user_id]
    site=Site.find session[:site_id]
    site.users << user
    redirect_to admin_site_users_path
  end

  page_action :remove, method: :get do
    user=User.find params[:user_id]
    site=Site.find session[:site_id]
    site.users.delete(user)
    redirect_to admin_site_users_path
  end

  content do
    session[:site_id] = params[:site_id] if params[:site_id]
    session[:site_id]=Site.order(:url).first.id unless session[:site_id]
    users=User

    users=users.name_contains(session[:user_name_filter]) if session[:user_name_filter]

    users=users.order(:name).limit(30)
    site=Site.find(session[:site_id])
    render partial: 'index', locals: { site: site, users: users }
  end

  sidebar :filters, partial: 'filters'
end
