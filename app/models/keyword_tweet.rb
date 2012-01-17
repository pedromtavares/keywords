class KeywordTweet < ActiveRecord::Base
  belongs_to :keyword
  belongs_to :tweet
end