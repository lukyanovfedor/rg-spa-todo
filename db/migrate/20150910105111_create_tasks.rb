class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :state, index: true
      t.date :deadline
      t.references :project, foreign_key: true, index: true
      t.timestamps null: false
    end
  end
end
