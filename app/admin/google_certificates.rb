ActiveAdmin.register GoogleCertificate do
  menu parent: 'Admin', priority: 5

  index do
    column :key
    column :start_on
    column :expire_at
    column :created_at
    actions
  end
end
