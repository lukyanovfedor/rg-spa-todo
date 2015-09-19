class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :state
      t.date :deadline

      t.timestamps null: false
    end

    add_index :tasks, :state
    add_reference :tasks, :project, foreign_key: true, index: true
  end
end
