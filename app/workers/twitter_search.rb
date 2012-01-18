class TwitterSearch
  @queue = :twitter_search_queue
  
  PAGES = 1
  BASIC_RANK = 30
  LOW_RANK = BASIC_RANK / 3
  HIGH_RANK = PAGES * BASIC_RANK
  CUTOFF = HIGH_RANK
  FOLLOW_MINIMUM = 20
  MAXIMUM_USERS = 50
  
  def self.perform(hash, user_id, search_id)
    begin
      high = hash['high']
      basic = hash['basic']
      low = hash['low']
      main_user = User.find(user_id)
      search = Search.find(search_id)
      search_settings = {:basic => {:rank => BASIC_RANK, :keywords => basic}, :low => {:rank => LOW_RANK, :keywords => low}, :high => {:rank => HIGH_RANK, :keywords => high}}
      twitter_rank = TwitterRank.new
      log = ''
    
      main_user.authenticate
      search.start
  
       # first step is to perform a search on twitter for these keywords
      search_settings.each do |priority, value|
        rank = value[:rank]
        keywords = value[:keywords]
        next if keywords.blank?
        keywords.each do |kw|
          log << "Searching for keyword: #{kw}\n"
          (1..PAGES).each do |page|
            log << "Searching page #{page} \n"
            results = Twitter.search("\"#{kw}\"", :page => page, :result_type => "recent", :lang => "en")
            unless results.blank?
              results.each do |result|
                twitter_rank.add_user(result['from_user'], result['text'], kw, rank, priority )
              end
            else
              log << "\nNo results were returned from searching #{kw} on page #{page}."
            end
          end
        end
      end
      
      log << "Finished searching Twitter, #{main_user.update_rate_limit_status} credits remaining this hour.\n"
              
      # filter out accounts that did not make the keyword ranking cutoff
      twitter_rank.users.delete_if {|user| user.rank < CUTOFF}
    
      # get top ranked accounts to avoid following a bunch of people at once
      unless twitter_rank.users.blank?
        sorted = twitter_rank.users.sort! {|x,y| y.rank <=> x.rank }
        sorted.slice!(MAXIMUM_USERS-1..sorted.size) if sorted.size > MAXIMUM_USERS 
      else
        log << "No relevant users were returned!\n"
      end
      
        
      # persist all data used
      log << "Saving records...\n"
      search.save_users(twitter_rank.users)
      search.finish
      log << "Search finished successfully."
      Resque.enqueue(EmailSender, main_user.id, search.id) if main_user.email.present?
    rescue => ex
      search.shit_happened(:search)
      log << "\n\nAn error has occurred in your search, please contact us and provide the text below: \n\n"
      log << ex.inspect
      log << "\n"
    ensure
      search.log!(log)
    end
  end
  
end

class TwitterRank
  attr_accessor :users, :counts
  def initialize
    @users = []
    @removed = []
    @counts = []
  end
  def add_user(name, tweet, keyword, rank, priority)
    user = @users.find{|user| user.name == name}
    if user.present?
      user.rank_up(tweet, keyword, rank, priority)
    else
      @users << RankTwitterUser.new(name, tweet, keyword, rank, priority)
    end
  end
  def filter(label, &block)
    @users.each do |user|
      block.call(user)
    end
    self.clean
    self.add_count(label)
  end
  def size
    @users.size
  end
  def remove(user)
    @removed << user
  end
  def clean
    @removed.each do |removed|
      @users.delete(removed)
    end
    @removed = []
  end
  def add_count(label)
    @counts << {:label => label, :size => self.size}
  end
end

class RankTwitterUser
  attr_accessor :name, :rank, :keywords
  def initialize(name, tweet, keyword, rank, priority)
    @name = name
    @rank = rank
    @keywords = []
    self.add_keyword(keyword, tweet, priority)
  end
  def rank_up(tweet, keyword, rank, priority)
    self.add_keyword(keyword, tweet, priority)
    self.rank += rank
  end
  def add_keyword(name, tweet, priority)
    keyword = @keywords.find{|kw| kw.name == name}
    if keyword.present?
      keyword.tweets << tweet
    else
      @keywords << RankKeyword.new(name, tweet, priority)
    end
  end
end

class RankKeyword
  attr_accessor :name, :tweets, :priority
  def initialize(name, tweet, priority)
    @name = name
    @tweets = [tweet]
    @priority = priority
  end
end
