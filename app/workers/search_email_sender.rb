class SearchEmailSender
  @queue = :search_emails_queue
  
  def self.perform(user_id, search_id)
    Notifications.search_finished(user_id, search_id).deliver
  end
end