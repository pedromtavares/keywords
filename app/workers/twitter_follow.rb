class TwitterFollow
  @queue = :twitter_follow_queue
  
  def self.perform(user_id, search_id)
    begin
      user = User.find(user_id)
      search = Search.find(search_id)
      log = ''
      user.authenticate
      log << "\nFollowing users...\n"
      search.twitter_users.each do |twitter_user|
        twitter_user.follow
        log << "Followed #{twitter_user.name}.\n"
      end  
      search.finish
    rescue => ex
      search.shit_happened(:follow)
      log << "An error has occurred when following user results, please contact us and provide the text below: \n\n"
      log << ex.inspect
      log << "\n"
      log << ex.backtrace.join("\n")
    ensure
      search.log!(search.log + log)
    end
  end
  
end
