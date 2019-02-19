class CreateGoogleCertificates < ActiveRecord::Migration
  def change
    create_table :google_certificates do |t|
      t.string :key
      t.text :body
      t.datetime :start_on, index: true
      t.datetime :expire_at, index: true

      t.timestamps null: false
    end
  end
end
