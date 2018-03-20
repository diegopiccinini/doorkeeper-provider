ActiveAdmin.register_page "Application Tags" do
  content do
    render partial: 'tags', locals: { applications: OauthApplication.order(:name).all }
  end
end
