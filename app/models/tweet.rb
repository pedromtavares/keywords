class Tweet < ActiveRecord::Base
  belongs_to :twitter_user
  has_many :keyword_tweets
  has_many :keywords, :through => :keyword_tweets
end