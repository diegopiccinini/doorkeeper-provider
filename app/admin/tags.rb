ActiveAdmin.register_page "Application Tags" do

  page_action :add_tag, method: :get do
    app=OauthApplication.find params[:app_id]
    tag=ActsAsTaggableOn::Tag.find params[:tag_id]
    app.tags << tag
    app.save
    redirect_to admin_application_tags_path, notice: "Tag #{tag.name} was added to #{app.name}"
  end

  page_action :remove_tag, method: :get do
    app=OauthApplication.find params[:app_id]
    tag=ActsAsTaggableOn::Tag.find params[:tag_id]
    app.tag_list.remove tag.name
    app.save
    redirect_to admin_application_tags_path, notice: "Tag #{tag.name} was removed to #{app.name}"
  end

  page_action :filter, method: :post do

    if params[:application_name].size>0
      session[:app_name_filter]=params[:application_name]
      notice_text= "Filter by application name #{params[:application_name]}"
    else
      session.delete(:app_name_filter)
      notice_text="filter deleted"
    end

    redirect_to admin_application_tags_path, notice: notice_text
  end
  content do
    if session[:app_name_filter]
      applications=OauthApplication.name_contains(session[:app_name_filter]).order(:name).limit(30).all
    else
      applications=OauthApplication.order(:name).limit(30).all
    end
    render partial: 'tags', locals: { applications: applications }
  end
  sidebar :filters, partial: 'filters'
end
