class SearchesController < InheritedResources::Base
  respond_to :html, :js
  before_filter :authentication_required
  
  def index
    @searches = paginate(current_user.searches.order('created_at desc'))
    super
  end
  
  def show
    if resource.user != current_user
      flash[:notice] = t('searches.no_permission')
      redirect_to root_path
    end
    super
  end
  
  def create
    keywords = {}
    [:low, :basic, :high].each {|type| keywords[type] = params[type]}
    @search = current_user.queue_search(keywords)
  end
  
  def restart
    resource.requeue
    flash[:success] = t('searches.restarted')
    redirect_to resource_path
  end
  
  def repeat
    new_search = resource.repeat
    flash[:success] = t('searches.created')
    redirect_to search_path(new_search)
  end
  
  def follow
    resource.follow_users
    flash[:success] = t('searches.follow')
    redirect_to resource_path
  end
end