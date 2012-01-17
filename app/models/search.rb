class Search < ActiveRecord::Base
  
  STATES = {:queued => 'queued', :started => 'started', :finished => 'finished', :following => 'following', :error => 'error'}
  ERRORS = {:search => 'search', :follow => 'follow'}
  
  belongs_to :user
  has_many :twitter_users, :dependent => :destroy
  has_many :keywords, :dependent => :destroy
  
  scope :latest, order('created_at desc').limit(5)
  
  def start
    self.update_attribute(:state, STATES[:started])
  end
  
  def finish
    self.update_attribute(:state, STATES[:finished])
  end
  
  def shit_happened(reason)
    self.state = STATES[:error]
    self.error = ERRORS[reason]
    self.save
  end
  
  def requeue
    self.update_attribute(:state, STATES[:queued])
    Resque.enqueue(TwitterSearch, self.keywords_to_hash, self.user.id, self.id)
  end
  
  def repeat
    self.user.queue_search(self.keywords_to_hash)
  end
  
  def follow_users
    self.update_attribute(:state, STATES[:following])
    Resque.enqueue(TwitterFollow, self.user.id, self.id)
  end
  
  # generates state querying methods
  STATES.keys.each do |state|
    class_eval %Q!
      def #{state.to_s}?
        self.state == STATES[:#{state}]
      end
    !
  end
  
  # generates error querying methods
  ERRORS.keys.each do |error|
    class_eval %Q!
      def #{error.to_s}_error?
        self.state == STATES[:error] && self.error == ERRORS[:#{error}]
      end
    !
  end
  
  def keywords_to_hash
    keywords = {'low' => [], 'basic' => [], 'high' => []}
    self.keywords.each {|kw| keywords[kw.priority] << kw.name}
    keywords
  end
  
  def save_keywords(keywords)
    keywords.each do |priority, words|
      next if words.blank?
      words.each do |word|
        self.keywords.create(:priority => priority, :name => word)
      end
    end
  end
  
  def save_users(users)
    users.each do |user|
      twitter_user = self.twitter_users.create(:name => user.name, :rank => user.rank)
      user.keywords.each do |keyword|
        created_keyword = self.keywords.find_or_create_by_name_and_priority(keyword.name, keyword.priority)
        keyword.tweets.each do |tweet|
          tweet = twitter_user.tweets.create(:body => tweet)
          created_keyword.tweets << tweet
          created_keyword.save
        end
      end
    end
  end
  
  def log!(text)
    self.update_attribute(:log, text)
  end
end