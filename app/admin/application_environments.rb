ActiveAdmin.register ApplicationEnvironment, as: "Stage Type" do
  member_action :lock, method: :put do
    resource.lock!
    redirect_to resource_path, notice: "Locked!"
  end

  filter :name
  filter :tags
  index do
    column :name
  end

end
