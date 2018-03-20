ActiveAdmin.register_page "Application Tags" do
  page_action :add_tag, method: :get do
    # ...
    redirect_to admin_application_tags_path, notice: "#{params} Your event was added"
  end
  content do
    render partial: 'tags', locals: { applications: OauthApplication.order(:name).all }
  end
end
