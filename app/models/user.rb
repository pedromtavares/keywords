class User < ActiveRecord::Base
  has_many :searches, :dependent => :destroy
  
  def queue_search(keywords)
    search = self.searches.create(:state => Search::STATES[:queued])
    search.save_keywords(keywords)
    Resque.enqueue(TwitterSearch, keywords, self.id, search.id)
    search
  end
  
  def self.create_from_omniauth(omniauth)
    User.create(:name => omniauth['info']['name'], :nickname => omniauth['info']['nickname'], :image_url => omniauth['info']['image'], :token => omniauth['credentials']['token'], :secret => omniauth['credentials']['secret'], :uid => omniauth['uid'])
	end
	
	def update_rate_limit_status
	  self.authenticate
	  limit = Twitter.rate_limit_status.remaining_hits.to_s
	  self.update_attribute(:rate_limit_status, limit)
	  limit
	end
	
	def authenticate
	  Twitter.configure do |config|
      config.oauth_token = self.token
      config.oauth_token_secret = self.secret
    end
	end
	
	def to_s
	  self.name.blank? ? self.nickname : self.name
	end
end