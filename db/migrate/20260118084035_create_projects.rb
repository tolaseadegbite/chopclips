class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.string :public_id, null: false
      t.string :title
      t.string :s3_key, null: false
      t.string :thumbnail_url

      # Integer Enum (0=queued, 1=processing...)
      t.integer :status, default: 0, null: false

      t.integer :duration_seconds
      t.jsonb :meta_data, default: {}

      t.timestamps
    end
    add_index :projects, :public_id, unique: true
    add_index :projects, :status
  end
end
