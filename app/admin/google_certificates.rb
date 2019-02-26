ActiveAdmin.register GoogleCertificate do
  menu parent: 'Admin', priority: 6

  index do
    column :key
    column :start_on
    column :expire_at
    column :created_at
    actions
  end
end
