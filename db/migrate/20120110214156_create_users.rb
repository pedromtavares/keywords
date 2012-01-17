class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :uid
      t.string :name
      t.string :nickname
      t.string :email
      t.string :image_url
      t.string :token
      t.string :secret
      t.string :rate_limit_status
      t.timestamps 
    end
  end
end
