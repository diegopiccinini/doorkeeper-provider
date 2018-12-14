ActiveAdmin.register ActsAsTaggableOn::Tag, as: "Tags" do

  menu parent: 'Admin', priority: 5

  permit_params :name

  config.batch_actions = false

  controller do
    def scoped_collection
      tags=OauthApplication.default_tags
      end_of_association_chain.where.not(name: tags)
    end
  end

  index do
    column :name
    actions
  end

  show do
    attributes_table do
      default_attribute_table_rows.each do |field|
        row field
      end

      row "Applications" do
        OauthApplication.tagged_with([resource.name]).map { |a| a.name }.join(' | ')
      end

    end
  end
end
