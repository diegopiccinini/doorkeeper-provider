class CreateApplicationEnvironments < ActiveRecord::Migration
  def change
    create_table :application_environments do |t|
      t.string :name , limit: 20
    end
    add_index :application_environments, :name, unique: true

    ApplicationEnvironment.create name: 'Production'
    ApplicationEnvironment.create name: 'Test'
    ApplicationEnvironment.create name: 'Development'
    ApplicationEnvironment.create name: 'Staging'
    ApplicationEnvironment.create name: 'Unknown'

  end
end
