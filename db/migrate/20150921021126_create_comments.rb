class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :note
      t.references :task
      t.json :files

      t.timestamps null: false
    end
  end
end
