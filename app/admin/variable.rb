ActiveAdmin.register Variable do

  config.batch_actions = false

  permit_params :name, :data

  index do
    column :name
    column :data
    actions
  end
end
