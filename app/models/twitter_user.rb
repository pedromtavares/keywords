class TwitterUser < ActiveRecord::Base
  belongs_to :search
  has_many :tweets, :dependent => :destroy

  def follow
    Twitter.follow(self.name)
    self.update_attribute(:followed, true)
  end
  
  def unfollow
    Twitter.unfollow(self.name)
    self.update_attribute(:followed, false)
  end
end