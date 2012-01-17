# TWITTER_ACCOUNT = "usedciscodotcom"
# 
# class TwitterRank
#   attr_accessor :users, :counts
#   def initialize
#     @users = []
#     @removed = []
#     @counts = []
#   end
#   def add_user(name, tweet, keyword, rank = 10)
#     user = @users.find{|user| user.name == name}
#     if user.present?
#       user.rank_up(rank, tweet, keyword)
#     else
#       @users << TwitterUser.new(name, tweet, keyword, rank)
#     end
#   end
#   def filter(label, &block)
#     @users.each do |user|
#       block.call(user)
#     end
#     self.clean
#     self.add_count(label)
#   end
#   def size
#     @users.size
#   end
#   def remove(user)
#     @removed << user
#   end
#   def clean
#     @removed.each do |removed|
#       @users.delete(removed)
#     end
#     @removed = []
#   end
#   def add_count(label)
#     @counts << {:label => label, :size => self.size}
#   end
# end
# 
# class TwitterUser
#   attr_accessor :name, :rank, :tweets, :keywords
#   def initialize(name, tweet, keyword, rank)
#     @name = name
#     @rank = rank
#     @tweets = [tweet]
#     @keywords = [keyword]
#   end
#   def rank_up(rank, tweet, keyword)
#     self.tweets << tweet
#     self.keywords << keyword
#     self.rank += rank
#   end
# end
# 
# namespace :twitter do
#   desc "Follows users that match a certain rank decided by tweets/bio/timeline containing certain keywords"
#   task :follow => :environment do
#     include TwitterControllerHelper
#     
#     PAGES = 5
#     BASE_RANK = 20
#     LOW_RANK = BASE_RANK / 4
#     HIGH_RANK = PAGES * BASE_RANK
#     CUTOFF = HIGH_RANK
#     FOLLOW_MINIMUM = 20
#     MAXIMUM_USERS = 50
#     
#     high = ['cisco', 'used cisco']
#     base = ["routing infrasctructure", "switching infrastructure", "unified communications", "ipv6", "borderless networks", "network storage", "router", "ip phone", "fiber channel", "voice gateway", "data center networking", "storage networking", "aggregation services", "unified communications", "telepresence", "communications manager", "integrated services"] 
#     low = ["wan", "gigabit", "lan", "catalyst", "inline power","tandberg", "blade server", "nexus", "switch", "firewall", "voip", "wireless"]
#     search_settings = {:base => {:rank => BASE_RANK, :keywords => base}, :low => {:rank => LOW_RANK, :keywords => low}, :high => {:rank => HIGH_RANK, :keywords => high}}
#     twitter_rank = TwitterRank.new
#     
#      # first step is to perform a search on twitter for these keywords
#     search_settings.each do |key, value|
#       rank = value[:rank]
#       keywords = value[:keywords]
#       keywords.each do |kw|
#         p "Searching for keyword: #{kw}"
#         (1..PAGES).each do |page|
#           p "Searching page #{page}"
#           search = twitter_connection.search("\"#{kw}\"", :page => page, :result_type => "recent", :lang => "en")
#           search_results = search['results'].map{|r| {:user => r['from_user'], :tweet => r['text']}}
#           search_results.each do |result|
#             twitter_rank.add_user(result[:user], result[:tweet], kw, rank)
#           end
#         end
#       end
#     end
#     twitter_rank.add_count("Total from search")
#     
#     # filter out accounts that did not make the keyword ranking cutoff
#     twitter_rank.users.delete_if {|user| user.rank < CUTOFF}
#     twitter_rank.add_count("Rank cutoff")    
#     
#     # filter out accounts that follow little or no people, which are probably information bots (like ourselves)
#     twitter_rank.filter("Following count") do |user|
#       p "Checking #{user.name}'s following count"
#       following = twitter_connection.friends_ids(:screen_name => user.name)
#       twitter_rank.remove(user) if following['ids'].blank? || following['ids'].size < FOLLOW_MINIMUM
#     end
#     
#     # filter out accounts that have little follower count, meaning that it could be a temp account (thus spam bot)
#     twitter_rank.filter("Follower count") do |user|
#       p "Checking #{user.name}'s follower count"
#       followers = twitter_connection.followers_ids(:screen_name => user.name)
#       twitter_rank.remove(user) if followers['ids'].blank? || followers['ids'].size < FOLLOW_MINIMUM
#     end
#     
#     # filter out accounts that we already follow
#     twitter_rank.filter("Already follow") do |user|
#       p "Checking if we already follow #{user.name}"
#       twitter_rank.remove(user) if twitter_connection.friends?(TWITTER_ACCOUNT, user.name)
#     end
#       
#     # get top ranked accounts so we don't follow a bunch of people at once (to avoid getting blocked by twitter)
#     sorted = twitter_rank.users.sort! {|x,y| y.rank <=> x.rank }
#     sorted.slice!(MAXIMUM_USERS-1..sorted.size) if sorted.size > MAXIMUM_USERS
#     sorted.each do |user|
#       puts "--------------------------------------------------------------------------------"
#       puts "Name: #{user.name} -- Rank: #{user.rank} -- Keywords: #{user.keywords.join(', ')}\nTweets: \n - #{user.tweets.join("\n - ")} \n"
#       puts "\n\n"
#     end
#     
#     # Finally, follow users that were left.
#     twitter_rank.users.each do |user|
#       result = twitter_connection.friend(user.name)
#       p "Just followed: #{result['screen_name']}"
#     end
#     
#     # Counts report to closely analyse numbers related to filters applied
#     twitter_rank.add_count("Final")
#     puts "\n\nDetailed counts (after filters were performed)"
#     twitter_rank.counts.each do |count|
#       puts "#{count[:label]} filter: #{count[:size]}"
#     end
#   end
#   
#   desc "Unfollows users that do not follow us"
#   task :unfollow => :environment do
#     include TwitterControllerHelper
#     retry_count = 0
#     begin
#       following = twitter_connection.friends_ids(:screen_name => TWITTER_ACCOUNT)
#       following['ids'].each do |id|
#         unless twitter_connection.friends?(id, TWITTER_ACCOUNT)
#           p "Just unfollowed #{id}."
#           twitter_connection.unfriend(id) 
#         else
#           p "#{id} follows us. No action taken"
#         end
#       end
#     rescue => ex
#       retry_count +=1
#       p "Retrying...count #{retry_count}"
#       retry unless retry_count > 10
#     end
#   end
# end