class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :refresh_token
      t.string :oauth_token

      t.timestamps
    end
  end
end
