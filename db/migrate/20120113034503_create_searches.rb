class CreateSearches < ActiveRecord::Migration

  def change
    create_table :searches do |t|
      t.references :user
      t.text :log
      t.string :state
      t.string :error
      t.timestamps
    end
    add_index :searches, :user_id
    
    create_table :keywords do |t|
      t.references :search
      t.string :name
      t.string :priority
      t.timestamps
    end
    add_index :keywords, :search_id
    
    create_table :twitter_users do |t|
      t.references :search
      t.string :name
      t.integer :rank
      t.boolean :followed, :default => false
      t.timestamps
    end
    add_index :twitter_users, :search_id
    
    create_table :tweets do |t|
      t.references :twitter_user
      t.text :body
      t.timestamps
    end
    add_index :tweets, :twitter_user_id
    
    create_table :keyword_tweets, :id => false do |t|
      t.references :keyword, :tweet
    end
    
  end
  
end
