class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title
      t.references :user, foreign_key: true, index: true
      t.timestamps null: false
    end
  end
end
