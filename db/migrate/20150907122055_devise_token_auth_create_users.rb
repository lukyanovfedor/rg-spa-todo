class DeviseTokenAuthCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      ## Required
      t.string :provider, :null => false, :default => "email"
      t.string :uid, :null => false, :default => ""

      t.string :encrypted_password, :null => false, :default => ""

      t.datetime :remember_created_at

      t.string :first_name
      t.string :last_name
      t.string :email

      t.json :tokens

      t.timestamps
    end

    add_index :users, :email
    add_index :users, [:uid, :provider],     :unique => true
  end
end
