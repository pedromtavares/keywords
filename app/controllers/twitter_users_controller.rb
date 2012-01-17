class TwitterUsersController < InheritedResources::Base
  respond_to :js
  
  def follow
    resource.follow
  end
  
  def unfollow
    resource.unfollow
  end
end