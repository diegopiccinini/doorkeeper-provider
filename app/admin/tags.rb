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

  content do
    render partial: 'tags', locals: { applications: OauthApplication.order(:name).all }
  end
end
