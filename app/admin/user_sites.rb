ActiveAdmin.register_page "User Sites" do

  menu false

  page_action :filter, method: :post do
    session[:site_name_filter]=params[:site_name]
    redirect_to admin_user_sites_path
  end

  page_action :clear_filter, method: :get do
    session.delete(:site_name_filter)
    redirect_to admin_user_sites_path
  end

  page_action :assigned, method: :get do
    session[:user_sites_assigned]='assigned'
    redirect_to admin_user_sites_path
  end

  page_action :unassigned, method: :get do
    session[:user_sites_assigned]='unassigned'
    redirect_to admin_user_sites_path
  end

  page_action :all, method: :get do
    session[:user_sites_assigned]='all'
    redirect_to admin_user_sites_path
  end

  page_action :add, method: :get do
    site=Site.find params[:site_id]
    user=User.find session[:user_id]
    user.sites << site
    redirect_to admin_user_sites_path
  end

  page_action :remove, method: :get do
    site=Site.find params[:site_id]
    user=User.find session[:user_id]
    user.sites.delete(site)
    redirect_to admin_user_sites_path
  end

  content do
    session[:user_sites_assigned]='all' unless session.has_key?(:user_sites_assigned)
    session[:user_id] = params[:user_id] if params[:user_id]
    session[:user_id]=User.order(:name).first.id unless session[:user_id]

    user=User.find(session[:user_id])

    if session[:user_sites_assigned]=='all'
      sites=Site
    elsif session[:user_sites_assigned]=='assigned'
      sites=user.sites
    else
      sites=Site.where.not(id: user.sites.ids)
    end

    sites=sites.url_contains(session[:site_name_filter]) if session[:site_name_filter]

    sites=sites.order(:url).limit(30)
    render partial: 'index', locals: { user: user, sites: sites }
  end

  sidebar :filters, partial: 'filters'
end

def style_button assigned
  button='warning'
  button='success' if session[:user_sites_assigned]==assigned
  "c-button c-button--#{button} c-button--block"
end
