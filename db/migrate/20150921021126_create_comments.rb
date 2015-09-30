class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :note
      t.references :task, foreign_key: true, index: true
      t.timestamps null: false
    end
  end
end
