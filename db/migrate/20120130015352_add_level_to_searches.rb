class AddLevelToSearches < ActiveRecord::Migration
  def change
    add_column :searches, :level, :string 
  end
end
