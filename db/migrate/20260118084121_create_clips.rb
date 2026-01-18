class CreateClips < ActiveRecord::Migration[8.1]
  def change
    create_table :clips do |t|
      t.references :project, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.string :public_id, null: false
      t.string :s3_key
      t.string :title

      # Integer Enum
      t.integer :status, default: 0, null: false

      t.float :start_time
      t.float :end_time
      t.text :transcript

      t.timestamps
    end
    add_index :clips, :public_id, unique: true
    add_index :clips, :status
  end
end
