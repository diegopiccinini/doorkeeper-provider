ActiveAdmin.register Variable do

  menu parent: 'Admin', priority: 7

  config.batch_actions = false

  permit_params :name, :data

  index do
    column :name
    column :data
    actions
  end
end
