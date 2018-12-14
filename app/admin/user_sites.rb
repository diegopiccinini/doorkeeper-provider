ActiveAdmin.register_page "User Sites" do

  menu parent: 'Users', priority: 2

  page_action :edit, method: :get do
    user=User.find(params[:user_id])
    render partial: 'edit', locals: { user: user }
  end

  page_action :filter, method: :post do
    session[:user_name_filter]=params[:user_name]
    redirect_to admin_user_sites_path
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
