ActiveAdmin.register Site do

  config.batch_actions = false

  index do
    column :url
    column :status
    column :step
    column :ip
    column :updated_at
    actions
  end

  filter :url
  filter :status
  filter :step
  filter :ip

end
