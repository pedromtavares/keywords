class Keyword < ActiveRecord::Base
  belongs_to :search
  has_many :keyword_tweets
  has_many :tweets, :through => :keyword_tweets
end