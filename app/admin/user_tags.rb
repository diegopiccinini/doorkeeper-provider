ActiveAdmin.register_page "User Tags" do

  menu parent: 'Users', priority: 3

  page_action :add_tag, method: :get do
    user=User.find params[:user_id]
    tag=ActsAsTaggableOn::Tag.find params[:tag_id]
    user.tags << tag
    user.save
    redirect_to admin_user_tags_path, notice: "Tag #{tag.name} was added to #{user.name}"
  end

  page_action :remove_tag, method: :get do
    user=User.find params[:user_id]
    tag=ActsAsTaggableOn::Tag.find params[:tag_id]
    user.tag_list.remove tag.name
    user.save
    redirect_to admin_user_tags_path, notice: "Tag #{tag.name} was removed to #{user.name}"
  end

  page_action :filter, method: :post do

    if params[:user_name].size>0
      session[:user_name_filter]=params[:user_name]
      notice_text= "Filter by user name #{params[:user_name]}"
    else
      session.delete(:user_name_filter)
      notice_text="filter deleted"
    end

    redirect_to admin_user_tags_path, notice: notice_text
  end

  page_action :filter_add_tag, method: :get do
    session[:filter_by_tag]<< params[:tag].to_i
    redirect_to admin_user_tags_path
  end

  page_action :filter_remove_tag, method: :get do
    session[:filter_by_tag].delete(params[:tag].to_i)
    redirect_to admin_user_tags_path
  end

  page_action :filter_clear, method: :get do
    session[:filter_by_tag]=[]
    session.delete(:user_name_filter)
    redirect_to admin_user_tags_path
  end

  content do
    session[:filter_by_tag]||=[]
    session[:filter_by_tag]=session[:filter_by_tag].uniq

    users=User
    tags=ActsAsTaggableOn::Tag.where(id: session[:filter_by_tag]).all
    users=users.tagged_with(tags) unless tags.empty?

    if session[:user_name_filter]
      users=users.where("name like ?","%#{session[:user_name_filter]}%")
    end
    render partial: 'tags', locals: { users: users.order(:name).limit(30).all }
  end

  sidebar :filters, partial: 'filters'
end
